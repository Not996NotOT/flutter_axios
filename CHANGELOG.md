# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-09-25

### Added

- **Core Features**
  - Promise-based HTTP client API inspired by Axios.js
  - Support for all HTTP methods (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS)
  - Automatic request body serialization (JSON, form data)
  - Automatic response data parsing
  - Request and response timeout support
  - Query parameters serialization

- **Instance Management**
  - Global Axios instance with static methods
  - Custom instance creation with `Axios.create()`
  - Instance configuration with `AxiosConfig`
  - Base URL support for relative requests

- **Interceptor System**
  - Request interceptors for modifying outgoing requests
  - Response interceptors for processing responses
  - Error interceptors for handling errors
  - Built-in interceptors:
    - `AuthInterceptor` for authentication headers
    - `HeadersInterceptor` for custom headers
    - `LoggingRequestInterceptor` for request logging
    - `LoggingResponseInterceptor` for response logging
    - `RetryInterceptor` for retry logic

- **Error Handling**
  - Comprehensive `AxiosError` class with error types:
    - Network errors
    - Timeout errors
    - HTTP response errors (4xx, 5xx)
    - Request cancellation errors
  - Detailed error information including request and response data

- **Request/Response Models**
  - `AxiosRequest` class for request representation
  - `AxiosResponse<T>` class for typed response handling
  - `RequestOptions` for configuring individual requests
  - Full TypeScript-like typing support

- **Progress Tracking**
  - Upload progress callbacks
  - Download progress callbacks
  - Progress tracking for file uploads/downloads

- **Configuration Options**
  - Request timeouts
  - Custom headers and query parameters
  - Response validation with custom status validators
  - Request/response transformation functions
  - Base URL configuration

- **Testing Support**
  - Mock-friendly architecture
  - Dependency injection for HTTP clients
  - Comprehensive test coverage

- **Documentation**
  - Complete API documentation
  - Usage examples and tutorials
  - Migration guide from http package
  - TypeScript-like API reference

### Technical Details

- Built on top of the `http` package for reliable HTTP communication
- Full Flutter and Dart compatibility
- Null-safety support
- Comprehensive error handling and logging
- Performance optimized for mobile applications

### Examples

- Basic GET/POST request examples
- Custom instance configuration examples
- Interceptor usage examples
- Error handling examples
- Progress tracking examples
