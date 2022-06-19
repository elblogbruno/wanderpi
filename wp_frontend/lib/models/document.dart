
class Document {
  final String documentId;
  final String documentName;

  final DateTime documentCreationDate;
  final DateTime documentUploadDate;

  final String documentThumbnailUri;
  final String documentImageUri;

  final String documentType;
  final String documentDescription;
  final String documentTravelId;

  Document({
    required this.documentId,
    required this.documentName,
    required this.documentCreationDate,
    required this.documentUploadDate,
    required this.documentImageUri,
    required this.documentThumbnailUri,
    required this.documentType,
    required this.documentDescription,
    required this.documentTravelId,
  });

  Document.fromJson(Map<dynamic, dynamic> json)
      : documentId = json['documentId'],
        documentName = json['documentName'],
        documentCreationDate = DateTime.parse(json['documentCreationDate']),
        documentUploadDate = DateTime.parse(json['documentUploadDate']),
        documentImageUri = json['documentImageUri'],
        documentThumbnailUri = json['documentThumbnailUri'],
        documentType = json['documentType'],
        documentDescription = json['documentDescription'],
        documentTravelId = json['documentTravelId'];


  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'documentId': documentId,
    'documentName': documentName,
    'documentCreationDate': documentCreationDate.toIso8601String(),
    'documentUploadDate': documentUploadDate.toIso8601String(),
    'documentImageUri': documentImageUri,
    'documentThumbnailUri': documentThumbnailUri,
    'documentType': documentType,
    'documentDescription': documentDescription,
    'documentTravelId': documentTravelId,
  };


  static Document randomFromInt(int i, String travelId) {
    return Document(
      documentId: 'documentId$i',
      documentName: 'documentName$i',
      documentCreationDate: DateTime.now(),
      documentUploadDate: DateTime.now(),
      documentImageUri: 'https://picsum.photos/1920/720?random=${i}',
      documentThumbnailUri: 'https://picsum.photos/400/300?random=${i}',
      documentType: 'documentType$i',
      documentDescription: 'documentDescription$i',
      documentTravelId: travelId,
    );
  }

  static Document getBusDocument(String query, List<Document> busDocuments)  {
    for (Document busDocument in busDocuments) {
      if (busDocument.documentId == query) {
        return busDocument;
      }
    }
    return busDocuments.first;
  }
}