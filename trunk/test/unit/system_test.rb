require File.dirname(__FILE__) + '/../test_helper'

class SystemTest < ActiveSupport::TestCase
  fixtures :systems

  # Test the license agreement.
  def test_license_agreement
    system = System.find(:first)
    system.license_agreement = "test"
    system.save(false)
    assert_equal "test", system.license_agreement
  end
end