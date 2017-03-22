class Api::V1::CoursesController < Api::V1::BaseApiController

  skip_before_action :set_course, only: [:index]
  skip_before_action :authorize_user_for_course, only: [:index]

  def index
    courses_for_user = User.courses_for_user current_user

    if params.has_key?(:state)
      if params[:state] == "disabled"
        courses_for_user = courses_for_user.select { |course| course.disabled? }
      elsif ["completed", "current", "upcoming"].include? params[:state]
        state = params[:state].to_sym
        courses_for_user = courses_for_user.select { |course| course.temporal_status == state }
      else
        # invalid state
        raise ApiError.new("Unexpected course state", :bad_request)
      end
    end

    # add auth level to the returned object
    courses_for_user = courses_for_user.map { |course| course.attributes.symbolize_keys }

    uid = current_user.id
    courses_for_user.each do |course|
      if current_user.administrator?
        course.merge!(:auth_level => "administrator")
        next
      end

      cud = CourseUserDatum.find_cud_for_course(course, uid)
      if cud.instructor?
        course.merge!(:auth_level => "instructor")
      elsif cud.course_assistant?
        course.merge!(:auth_level => "course_assistant")
      else
        course.merge!(:auth_level => "student")
      end
    end

    respond_with courses_for_user, only: [:name, :display_name, :semester, :late_slack, :grace_days, :auth_level]
  end

end