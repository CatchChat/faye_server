require 'spec_helper'
require 'xinge'
describe Xinge::ClickAction do
  subject {
    Xinge::ClickAction.new(
      action_type: Xinge::ClickAction::ACTION_TYPE_ACTIVITY,
      activity: 'xxx',
      aty_attr: { if: 0, pf: 0 },
      browser: { url: 'xxxx', confirm: 1 },
      intent: 'xxx',
      package_name: {
        packageDownloadUrl: 'xxxx',
        confirm: 1,
        packageName: 'com.demo.xg'
      }
    )
  }

  describe '#format' do
    it 'action_type is ACTION_TYPE_ACTIVITY' do
      subject.action_type = Xinge::ClickAction::ACTION_TYPE_ACTIVITY
      expect(subject.format).to eq({ action_type: 1, activity: "xxx", aty_attr: { if: 0, pf: 0 } })
    end

    it 'action_type is ACTION_TYPE_BROWSER' do
      subject.action_type = Xinge::ClickAction::ACTION_TYPE_BROWSER
      expect(subject.format).to eq({ action_type: 2, browser: { url: "xxxx", confirm: 1} })
    end

    it 'action_type is ACTION_TYPE_INTENT' do
      subject.action_type = Xinge::ClickAction::ACTION_TYPE_INTENT
      expect(subject.format).to eq({ action_type: 3, intent: "xxx" })
    end

    it 'action_type is ACTION_TYPE_PACKAGE_NAME' do
      subject.action_type = Xinge::ClickAction::ACTION_TYPE_PACKAGE_NAME
      expect(subject.format).to eq({
        action_type: 4,
        package_name: {
          packageName: "com.demo.xg",
          packageDownloadUrl: "xxxx",
          confirm: 1
        }
      })
    end
  end
end
