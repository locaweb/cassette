# encoding: UTF-8

require 'active_support/concern'

module Cassette
  module Rubycas
    module Helper
      extend ActiveSupport::Concern
      extend UserFactory

      included do
        before_filter :validate_authentication_ticket
        helper_method :current_user
      end

      module ClassMethods
        def skip_authentication(*options)
          skip_before_filter :validate_authentication_ticket, *options
        end
      end

      def validate_authentication_ticket
        return if ENV['NOAUTH']
        ::CASClient::Frameworks::Rails::Filter.filter(self)
      end

      def employee_only_filter
        return if ENV['NOAUTH'] || current_user.blank?
        fail Cassette::Errors::NotAnEmployee unless current_user.employee?
      end

      def customer_only_filter
        return if ENV['NOAUTH'] || current_user.blank?
        fail Cassette::Errors::NotACustomer unless current_user.customer?
      end

      def cas_logout(to = root_url)
        session.destroy
        ::CASClient::Frameworks::Rails::Filter.logout(self, to)
      end

      def fake_user
        Cassette::Authentication::User.new(login: 'fake.user',
                                           name: 'Fake User',
                                           email: 'fake.user@locaweb.com.br',
                                           authorities: [],
                                           type: 'customer')
      end

      def validate_role!(role)
        return if ENV['NOAUTH']
        fail Cassette::Errors::Forbidden unless current_user.has_role?(role)
      end

      def validate_raw_role!(role)
        return if ENV['NOAUTH']
        fail Cassette::Errors::Forbidden unless current_user.has_raw_role?(role)
      end

      def current_user
        return fake_user if ENV['NOAUTH']
        return nil unless session[:cas_user]

        @current_user ||= from_session(session)
      end
    end
  end
end
