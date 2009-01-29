require 'test_helper'

class IphoneAuthSignatureTest < ActiveSupport::TestCase
  def setup
    @device_id = '12345' * 8
    @signature = IphoneAuthFilters.signature @device_id
    @version = IphoneAuthFilters.signature_version
  end

  def test_signing_algorithm_is_correct
    assert_equal "c9acca7ec91004c549b09699d9404af28196e5488b94f70c87c44be05a19c694",
                 @signature
  end

  def test_valid_signature_works
    assert IphoneAuthFilters.is_good_signature(@device_id, @signature, @version)
  end

  def test_invalid_version_fails
    @version[0] = '2'
    assert !IphoneAuthFilters.is_good_signature(@device_id, @signature,
                                                @version)
  end

  def test_invalid_signature_fails
    @signature[10] = ?2
    assert !IphoneAuthFilters.is_good_signature(@device_id, @signature,
                                                @version)
  end

  def test_invalid_device_id_fails
    @device_id[10] = ?4
    assert !IphoneAuthFilters.is_good_signature(@device_id, @signature,
                                                @version)
  end
end
