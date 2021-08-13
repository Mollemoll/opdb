# frozen_string_literal: true

module ApiExceptions
  class ApiExceptionError < StandardError; end

  class BadRequestError < ApiExceptionError; end

  class UnauthorizedError < ApiExceptionError; end

  class ForbiddenError < ApiExceptionError; end

  class NotFoundError < ApiExceptionError; end

  class UnprocessableEntityError < ApiExceptionError; end

  class ApiError < ApiExceptionError; end
end
