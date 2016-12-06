require 'digest/sha1'

class Individual < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :company
  has_and_belongs_to_many :projects, -> {where(deleted_at: nil)}
  belongs_to :selected_project, :class_name => "Project", :foreign_key => "selected_project_id"
  belongs_to :team
  has_many :stories, -> {where(deleted_at: nil)}, dependent: :nullify
  has_many :individual_story_attributes, :dependent => :destroy
  has_many :tasks, -> {where(deleted_at: nil)}, dependent: :nullify
  has_many :user_errors, :dependent => :destroy, :class_name => 'Error'
  audited :except => [:selected_project_id, :crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code, :activated_at, :last_login, :accepted_agreement]

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email, :first_name, :last_name, :role, :notification_type
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 2..40
  validates_length_of       :first_name,    :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :last_name,    :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  validates_numericality_of :role, :notification_type
  validates_format_of       :phone_number, :message => "must be a valid telephone number", :with => /\A[\(\)0-9\- \+\.]{10,20}\z/, :allow_nil => true, :allow_blank => true
  validate :validate
  validate :validate_on_create, on: :create
  validate :validate_on_update, on: :update

  # Ensure that the individual's email address is validated.
  before_create :make_activation_code
  
  # Ensure that the password is encrypted
  before_save :encrypt_password

  Admin = 0
  ProjectAdmin = 1
  ProjectUser = 2
  ReadOnlyUser = 3
  
  NoNotifications = 0
  EmailNotifications = 1
  SMSNotifications = 2
  BothNotifications = 3

  # Authenticates an individual by their login name and unencrypted password.  Returns the individual or nil.
  def self.authenticate(login, password)
    # Authentication uses case insensitive login comparison (password is case sensitive)
    individual = where(['STRCMP( login, :login)=0 and activated_at IS NOT NULL and enabled', {login: login}]).first # need to get the salt
    individual && individual.authenticated?(password) ? individual : nil
  end

  # Answer if a password is valid for this individual.
  def authenticated?(password)
   if(Rails.configuration.use_ldap)
     Authenticate.ldap(self.login, password)
   else
     crypted_password == encrypt(password)
   end
  end

  # Find the individual for a particular activation code and activate it.  Answer
  # the individual if successful or nil otherwise.
  def self.activate( activation_code )
    if activation_code && individual = find_by_activation_code(activation_code)
      individual.activate!
      individual
    end    
  end

  # Activate the user (i.e., we've validated that the email address for the individual is valid).
  def activate!
    self.activated_at = Time.now.utc
  end

  # Answer whether the individual has been activated.
  def activated?
    # the existence of an activation code means they have not been activated
    activated_at != nil
  end

  # Remember this individual on the browser for two weeks so that they don't have to log in.
  def remember_me
    remember_me_for 2.weeks
  end

  # Forget this individual on the browser, forcing log in.
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
  end

  # Answer whether we should still remember this individual.
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # Override attributes= to handle project_ids.
  def assign_attributes(new_attributes)
    @changed_attributes = changes
    keys_to_remove = [:agreement_accepted]
    new_attributes.each_pair do |key, value|
      if key.to_sym == :project_id
        keys_to_remove << key
        @changed_attributes['project_id'] = [project_ids, nil]
        projects.clear
        if (value)
          projects << Project.find(value)
        end
        if (changed_attributes['project_id'][0] == project_ids)
          @changed_attributes.delete('project_id')
        else
          @changed_attributes['project_id'][1] = project_ids
        end
      end
      if key.to_sym == :project_ids
        keys_to_remove << key
        @changed_attributes['project_id'] = [project_ids, nil]
        projects.clear
        if (value)
          value.split(",").each {|project_id| projects << Project.find(project_id)}
        end
        if (changed_attributes['project_id'][0] == project_ids)
          @changed_attributes.delete('project_id')
        else
          @changed_attributes['project_id'][1] = project_ids
        end
      end
    end
    keys_to_remove.each {|key| new_attributes.delete(key)} # Prevents warning
    super(new_attributes)
  end

  # Answer how I should be displayed to the user.
  def name
    "#{first_name} #{last_name}"
  end

  # Override as_json to exclude private attributes.
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code, :accepted_agreement, :created_at, :updated_at, :deleted_at]
    end
    if !options[:methods]
      options[:methods] = [:project_ids]
    end
    super(options)
  end  

  # Prettier method name for json.
  def activated
    activated?
  end
  
  def project
    selected_project
  end  

  def project_id
    selected_project_id
  end

  def selected_project
    selected_project_id ? Project.find(selected_project_id) : nil
  end
  
  def selected_project_id
    primitive = read_attribute(:selected_project_id)
    primitive ? primitive : (projects.empty? ? nil : projects[0].id)
  end
  
  def project_ids
    projects.collect {|project|project.id}.join(',')
  end

  # Answer whether records have changed.
  def self.have_records_changed(current_user, time)
    if current_user.role >= Individual::ProjectAdmin # Note: updated_at is >, not >= to ignore the change from logging in
      Individual.with_deleted.where(["company_id = :company_id and role in (1,2,3) and (updated_at > :time or deleted_at >= :time)", {company_id: current_user.company_id, time: time}]).count > 0
    else
      Individual.with_deleted.where(["updated_at >= :time or deleted_at >= :time", {time: time}]).count > 0
    end
  end

  # Answer the records for a particular user.
  def self.get_records(current_user)
    if current_user.role >= Individual::ProjectAdmin
      if current_user.is_premium
        joins(:projects).includes(:projects).where(["individuals.company_id = :company_id and role in (1,2,3)", {company_id: current_user.company_id}]).order('first_name, last_name')
      else
        joins(:projects).includes(:projects).where(["(projects.id = :project_id and role in (1,2,3)) or individuals.id=:user_id", {project_id: current_user.project_id, user_id: current_user.id}]).order('first_name, last_name')
      end
    elsif current_user.selected_project
      users = where(["company_id = :company_id", {company_id: current_user.selected_project.company_id}]).order('first_name, last_name')
      !users.include?(current_user) ? users << current_user : users
    else
      Array[current_user]
    end
  end

  # Only project admins or higher can create individuals.
  def authorized_for_create?(current_user)
    if current_user.role <= Individual::Admin
      true
    elsif current_user.role <= Individual::ProjectAdmin
      (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
    else
      false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
      else current_user.id == id
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then id != current_user.id
      when Individual::ProjectAdmin then id != current_user.id && (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
      else false
    end
  end
   
  # Too many users have been added.
  def count_exceeded
    errors.add(:base, "Too many users exist to make this change.  To address the issue, delete or disable a user or contact support to extend your limits.")
  end

  # Answer whether I am enabled for premium services.
  def is_premium
    !company || company.is_premium
  end

  # Notify that something has occurred.
  def send_notification(project, subject, message)
    if is_premium
      if notification_type == EmailNotifications || notification_type == BothNotifications
        PLANIGLE_EMAIL_NOTIFIER.send_notification(project, email, subject, message)
      end
  
      if (notification_type == SMSNotifications || notification_type == BothNotifications) && phone_number && phone_number != ''
        PLANIGLE_SMS_NOTIFIER.send_notification(project, phone_number, subject, message)
      end
    end
  end

  def current_user_project
    @current_user_project
  end

  def current_user_project= a_project
    @current_user_project = a_project
  end

  # Answer my capacity based on my load over the past 3 iterations
  def capacity
    if projects.include? self.current_user_project
      iterations = current_user_project.iterations.includes(:stories => :tasks).where('finish <= CURDATE()').order('start desc').first(3)
      iterations.size > 0 ? iterations.inject(0) {|sum, iteration| sum + utilization_in(iteration)} / iterations.size : nil
    else
      nil
    end
  end
  
  # Answer my utilization in an iteration
  def utilization_in(iteration)
    iteration.stories.inject(0) do |storyTotal, story|
      storyTotal + story.tasks.inject(0) do |sum, task|
        if task.individual_id == id and task.status_code == Story.Done
          sum + (task.actual ? task.actual : (task.estimate ? task.estimate : 0))
        else
          sum
        end
      end
    end
  end
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end

protected

  # Remember this individual on the browser for the specified amount of time so that they
  # don't have to log in.
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  # Remember this individual on the browser until the specified time so that they
  # don't have to log in.
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
  end

  # Returns the password encrypted with my salt.
  def encrypt(password)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypt the password before saving.
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  # Answer if the password is being changed / needs to be changed.
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  # Set my activation code.
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # Ensure that the premium limit is not exceeded.
  def validate_on_create
    if will_impact_limits
      count_exceeded
    end
  end
  
  # Ensure that the premium limit is not exceeded.
  def validate_on_update
    if will_impact_limits
      if (role_changed? && role_was >= ReadOnlyUser && role < ReadOnlyUser) ||
        (enabled_changed? && !enabled_was && enabled)
        count_exceeded
      end
    end
  end

  # Answer whether if saved, I will cause the premium limits to be exceeded.
  def will_impact_limits
    role < ReadOnlyUser && enabled && company && !company.can_add_users
  end

  # Add custom validation of the role field.
  def validate
    if role && (role < Admin || role > ReadOnlyUser)
      errors.add(:role, 'is invalid')
    end
    
    if role && (role > Admin && !company_id )
      errors.add(:company, 'must be set for users who are not admins')
    end
    
    if role && (role > Admin && projects.empty? )
      errors.add(:project, 'must be set for users who are not admins')
    end

    if notification_type && (notification_type < NoNotifications || notification_type > BothNotifications)
      errors.add(:notification_type, 'is invalid')
    end    
    
    if notification_type && (notification_type == SMSNotifications || notification_type == BothNotifications) && (!phone_number || phone_number == '')
      errors.add(:phone_number, 'must be set in order to send SMS notifications')
    end    
    
    projects.each do |project|
      if company_id != project.company_id
        errors.add(:project, 'must be associated with company')
      end
    end

    if team && (!projects.detect{|project|team.project == project})
      errors.add(:team, 'must be associated with project')
    end
    
    if selected_project && company && selected_project.company != company && role > Admin
      if errors.empty?
        self.selected_project_id = nil
      end
    end
  end
end
