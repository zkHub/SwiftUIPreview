require 'xcodeproj'

module Fastlane
  module Actions
    class GetBundleidAction < Action
      def self.run(params)
        project_path = params[:xcodeproj]
        target_name = params[:target]
        configuration = params[:configuration] || "Release"

        UI.user_error!("请提供有效的 xcodeproj 路径") unless File.exist?(project_path)

        project = Xcodeproj::Project.open(project_path)
        target = project.targets.find { |t| t.name == target_name }

        UI.user_error!("未找到名为 '#{target_name}' 的 target") unless target

        build_config = target.build_configurations.find { |config| config.name == configuration }

        UI.user_error!("未找到配置 '#{configuration}'") unless build_config

        bundle_id = build_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"]

        UI.user_error!("未在配置中找到 PRODUCT_BUNDLE_IDENTIFIER") unless bundle_id

        UI.message("获取到的 Bundle Identifier: #{bundle_id}")
        return bundle_id
      end

      def self.description
        "根据指定的 target 和配置获取实际的 Bundle Identifier"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "GET_BUNDLE_IDENTIFIER_XCODEPROJ",
                                       description: "Xcode 项目的路径",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "GET_BUNDLE_IDENTIFIER_TARGET",
                                       description: "Target 的名称",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "GET_BUNDLE_IDENTIFIER_CONFIGURATION",
                                       description: "构建配置（如 Debug 或 Release）",
                                       optional: true,
                                       type: String,
                                       default_value: "Release")
        ]
      end

      def self.authors
        ["Your Name"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
