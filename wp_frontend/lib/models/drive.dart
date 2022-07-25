class Drive {
  final String memoryType;
  final String memoryAccessUri;
  final String memoryId;

  Drive({
    required this.memoryType,
    required this.memoryAccessUri,
    required this.memoryId,
  });

  Drive.fromJson(Map<dynamic, dynamic> json)
      : memoryType = json['memory_type'],
        memoryAccessUri = json['memory_access_uri'],
        memoryId = json['memory_id'];


  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'memory_type': memoryType,
        'memory_access_uri': memoryAccessUri,
        'memory_id': memoryId,
      };
}