# frozen_string_literal: true
require 'jwt/json'

# JWT::Encode module
module JWT
  extend JWT::Json

  # Encoding logic for JWT
  class Encode
    attr_reader :payload, :key, :algorithm, :header_fields, :segments

    def initialize(payload, key, algorithm, header_fields)
      @payload = payload
      @key = key
      @algorithm = algorithm
      @header_fields = header_fields
      @segments = encode_segments
    end

    private

    def encoded_header(algorithm, header_fields)
      header = { 'alg' => algorithm }.merge(header_fields)
      JWT.base64url_encode(JWT.encode_json(header))
    end

    def encoded_payload(payload)
      raise InvalidPayload, 'exp claim must be an integer' if payload['exp'] && payload['exp'].is_a?(Time)
      JWT.base64url_encode(JWT.encode_json(payload))
    end

    def encoded_signature(signing_input, key, algorithm)
      if algorithm == 'none'
        ''
      else
        signature = JWT.sign(algorithm, signing_input, key)
        JWT.base64url_encode(signature)
      end
    end

    def encode_segments
      segments = []
      segments << encoded_header(@algorithm, @header_fields)
      segments << encoded_payload(@payload)
      segments << encoded_signature(segments.join('.'), @key, @algorithm)
      segments.join('.')
    end
  end
end
