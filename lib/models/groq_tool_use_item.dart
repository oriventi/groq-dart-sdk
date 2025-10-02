/// Represents an individual tool that can be registered and used with Groq API.
///
/// Each tool consists of a name, description, a list of parameters,
/// and a function that implements the tool's functionality.
class GroqToolItem {
  /// The unique name of the function (must be ≤ 64 characters).
  final String functionName;

  /// A brief description of the function's purpose.
  final String functionDescription;

  /// A list of parameters required by the function.
  final List<GroqToolParameter> parameters;

  /// The function to be executed. It takes a map of arguments as input and returns a dynamic value.
  final dynamic Function(Map<String, dynamic> args) function;

  /// Creates a GroqToolItem with a name, description, parameters, and function.
  ///
  /// [functionName]: The name of the function (≤ 64 characters).
  /// [functionDescription]: A description of the function's purpose.
  /// [parameters]: A list of parameters required by the function.
  /// [function]: The function to execute, taking a map of arguments.
  GroqToolItem({
    required this.functionName,
    required this.functionDescription,
    required this.parameters,
    required this.function,
  }) {
    assert(functionName.length <= 64,
        'Function name must be less than or equal to 64 characters');
    assert(parameters.length <= 128,
        'Function parameters must be less than or equal to 128 characters');
  }

  /// Validates and returns the registered tool function with the given arguments.
  /// [arguments]: A map where keys are parameter names and values are their corresponding arguments. The names must match the parameter names of the function.
  ///Example:
  ///```dart
  /// final weatherTool = GroqToolItem(
  ///   functionName: 'get_weather',
  ///   functionDescription: 'Get weather information for a specified location',
  ///   parameters: [
  ///     GroqToolParameter(
  ///       parameterName: 'location',
  ///       parameterDescription: 'City or location name',
  ///       parameterType: GroqToolParameterType.string,
  ///       isRequired: true,
  ///     ),
  ///     GroqToolParameter(
  ///       parameterName: 'units',
  ///       parameterDescription: 'Temperature units (metric or imperial)',
  ///       parameterType: GroqToolParameterType.string,
  ///       isRequired: false,
  ///       allowedValues: ['metric', 'imperial'],
  ///     ),
  ///   ],
  ///   function: (args) {
  ///     final location = args['location'] as String;
  ///     final units = args['units'] as String? ?? 'metric';
  ///     return {
  ///       'location': location,
  ///       'temperature': units == 'metric' ? 22 : 71.6,
  ///       'units': units,
  ///     };
  ///   },
  /// );
  /// try {
  ///   final result = weatherTool.execute({
  ///     'location': 'London',
  ///     'units': 'metric',
  ///   });
  ///   print('Weather result: $result');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  ///```
  /// Validates the arguments and returns a callable function.
  ///
  /// [arguments]: A map where keys are parameter names and values are their corresponding arguments.
  ///
  /// Returns a callable function that, when invoked, executes the registered function.
  Function validateAndGetCallable(Map<String, dynamic> arguments) {
    for (var param in parameters) {
      if (param.isRequired && !arguments.containsKey(param.parameterName)) {
        print(
            'Missing required parameter: ${param.parameterName} in $arguments');
        throw ArgumentError(
            'Missing required parameter: ${param.parameterName}');
      }

      if (arguments.containsKey(param.parameterName)) {
        final value = arguments[param.parameterName];

        // Validate type
        switch (param.parameterType) {
          case GroqToolParameterType.string:
            if (value is! String) {
              throw ArgumentError(
                  'Parameter ${param.parameterName} must be a String');
            }
            break;
          case GroqToolParameterType.number:
            if (value is! num) {
              throw ArgumentError(
                  'Parameter ${param.parameterName} must be a Number');
            }
            break;
          case GroqToolParameterType.boolean:
            if (value is! bool) {
              throw ArgumentError(
                  'Parameter ${param.parameterName} must be a Boolean');
            }
            break;
          case GroqToolParameterType.array:
            if (value is! List) {
              throw ArgumentError(
                  'Parameter ${param.parameterName} must be an Array');
            }
            // Validate each element in the array
            for (var i = 0; i < value.length; i++) {
              final element = value[i];
              // Validate element type
              switch (param.itemType!) {
                case GroqToolParameterType.string:
                  if (element is! String) {
                    throw ArgumentError(
                        'Parameter ${param.parameterName}[$i] must be a String');
                  }
                  break;
                case GroqToolParameterType.number:
                  if (element is! num) {
                    throw ArgumentError(
                        'Parameter ${param.parameterName}[$i] must be a Number');
                  }
                  break;
                case GroqToolParameterType.boolean:
                  if (element is! bool) {
                    throw ArgumentError(
                        'Parameter ${param.parameterName}[$i] must be a Boolean');
                  }
                  break;
                case GroqToolParameterType.array:
                  throw ArgumentError(
                      'Nested arrays are not supported');
              }
              // Validate element against allowed values
              if (param.allowedValues.isNotEmpty &&
                  !param.allowedValues.contains(element.toString())) {
                throw ArgumentError(
                    'Parameter ${param.parameterName}[$i] must be one of ${param.allowedValues}');
              }
            }
            break;
        }

        // Validate allowed values for non-array types
        if (param.parameterType != GroqToolParameterType.array &&
            param.allowedValues.isNotEmpty &&
            !param.allowedValues.contains(value.toString())) {
          throw ArgumentError(
              'Parameter ${param.parameterName} must be one of ${param.allowedValues}');
        }
      }
    }

    // Return a callable function
    return () => function(arguments);
  }

  @override
  int get hashCode => functionName.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroqToolItem && other.functionName == functionName;
  }
}

/// Represents the data type of a Groq tool parameter.
enum GroqToolParameterType {
  string,
  number,
  boolean,
  array,
}

/// Represents a parameter for a Groq tool.
///
/// Each parameter has a name, description, type, and optional constraints.
class GroqToolParameter {
  /// The name of the parameter.
  final String parameterName;

  /// A description of what the parameter does.
  final String parameterDescription;

  /// The data type of the parameter.
  final GroqToolParameterType parameterType;

  /// Whether this parameter must be provided when calling the function.
  final bool isRequired;

  /// A list of allowed values for this parameter.
  ///
  /// When non-empty, the parameter value must match one of these values.
  /// This is particularly useful for parameters that accept a fixed set of options.
  /// The allowed values must matche the value's `toString()` method.
  /// If the parameter is not required, the allowed values are only enforced if the parameter is provided.
  /// For example, a "units" parameter might only accept ["metric", "imperial"].
  /// For array types, this restricts the values of array elements.
  final List<String> allowedValues;

  /// The type of elements in the array (only used when parameterType is array).
  ///
  /// When [parameterType] is [GroqToolParameterType.array], this field specifies
  /// what type each element in the array should be.
  /// For example, if you want an array of strings, set this to [GroqToolParameterType.string].
  final GroqToolParameterType? itemType;

  /// Creates a new parameter definition for a Groq tool.
  ///
  /// [parameterName]: The name of the parameter.
  /// [parameterDescription]: A description of what the parameter does.
  /// [parameterType]: The type of data this parameter accepts.
  /// [isRequired]: Whether this parameter must be provided.
  /// [allowedValues]: If provided, restricts the parameter to these values (or array elements for array types).
  /// [itemType]: Required when parameterType is array - specifies the type of array elements.
  GroqToolParameter({
    required this.parameterName,
    required this.parameterDescription,
    required this.parameterType,
    required this.isRequired,
    this.allowedValues = const [],
    this.itemType,
  }) {
    if (parameterType == GroqToolParameterType.array) {
      assert(itemType != null,
          'itemType must be specified when parameterType is array');
      assert(itemType != GroqToolParameterType.array,
          'itemType cannot be array (nested arrays not supported)');
    }
  }
}
