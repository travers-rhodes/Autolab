FactoryGirl.define do
  factory :tango do
    host "MyString"
    port "MyString"
    timeout ""
    max_dead_jobs ""
    def_dead_jobs ""
    key "MyString"
    use_polling ""
  end
end
