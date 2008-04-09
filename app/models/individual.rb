require 'digest/sha1'
class Individual < ActiveRecord::Base
  has_many :stories, :dependent => :nullify
  has_many :tasks, :dependent => :nullify

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email, :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 2..40
  validates_length_of       :first_name,    :within => 1..40
  validates_length_of       :last_name,    :within => 1..40
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i

  # Ensure that the individual's email address is validated.
  before_create :make_activation_code
  
  # Ensure that the password is encrypted
  before_save :encrypt_password

  # Prevent a user from submitting a crafted form that bypasses activation
  # Anything that the user can change should be added here.
  attr_accessible :login, :email, :first_name, :last_name, :password, :password_confirmation, :enabled

  # Authenticates an individual by their login name and unencrypted password.  Returns the individual or nil.
  def self.authenticate(login, password)
    # Authentication uses case insensitive login comparison (password is case sensitive)
    individual = find :first, :conditions => ['STRCMP( login, ?)=0 and activated_at IS NOT NULL and enabled', login] # need to get the salt
    individual && individual.authenticated?(password) ? individual : nil
  end

  # Answer if a password is valid for this individual.
  def authenticated?(password)
    crypted_password == encrypt(password)
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

  # Answer how I should be displayed to the user.
  def name
    "#{first_name} #{last_name}"
  end

  # Override to_xml to exclude private attributes.
  def to_xml(options = {})
    if !options[:except]
      options[:except] = [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code, :activated_at ]
    end
    if !options[:methods]
      options[:methods] = [:activated]
    end
    super(options)
  end

  # Prettier method name for xml.
  def activated
    activated?
  end
 
private

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
end
