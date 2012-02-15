module MetasploitDataModels::ActiveRecordModels::User
  def self.included(base)
    base.class_eval {
      include Msf::DBManager::DBSave
      extend MetasploitDataModels::SerializedPrefs
      serialize :prefs, ::MetasploitDataModels::Base64Serializer.new

      has_and_belongs_to_many :workspaces, :join_table => "workspace_members", :uniq => true, :class_name => "Mdm::Workspace"
      has_many :owned_workspaces, :foreign_key => "owner_id", :class_name => "Mdm::Workspace"
      has_many :tags, :class_name => "Mdm::Tag"

      validates :password, :password_is_strong => true
      validates :password_confirmation, :password_is_strong => true
      validate { |user| available_license?(user) }

      serialized_prefs_attr_accessor :nexpose_host, :nexpose_port, :nexpose_user, :nexpose_pass, :nexpose_creds_type, :nexpose_creds_user, :nexpose_creds_pass
      serialized_prefs_attr_accessor :http_proxy_host, :http_proxy_port, :http_proxy_user, :http_proxy_pass
      serialized_prefs_attr_accessor :time_zone, :session_key
      serialized_prefs_attr_accessor :last_login_address # specifically NOT last_login_ip to prevent confusion with AuthLogic magic columns (which dont work for serialized fields)

      private

      def available_license?(user)
        if user.new_record? && license_count_exceeded?
          user.errors[:base] << "You've reached the user limit on this license"
        end
      end

      def license_count_exceeded?
        self.class.count >= License.get.users
      end

    }
  end
end
