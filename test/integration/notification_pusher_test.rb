require 'test_helper'

class NotificationPusherTest < ActionController::IntegrationTest
  fixtures :all
  
  # Normally, Rails runs the entire test in a transaction, so the database
  # changes done in test are isolated from the database changes made by daemons.
  # The line can be removed if the test and the daemon don't communicate via the
  # database.
  self.use_transactional_fixtures = false

  test "daemon interactions" do
	  # stuff that should be done before the daemon runs (e.g. database setup)
		
    Daemonz.with_daemons do
      # Wait 5 seconds for the notifications to be pushed.
      50.times do
        sleep 0.1        
        break if ImobilePushNotification.count == 0
      end

      assert_equal 0, ImobilePushNotification.count,
                   'Push notifications not delivered'
    end
  end
end
