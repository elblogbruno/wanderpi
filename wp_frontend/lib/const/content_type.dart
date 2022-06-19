import 'package:flutter/material.dart';

enum ContentType {
  Web,
  Text,
  Image,
  Audio,
  Video,
  File,
  Notification,
  Task,
}  // enum ContentType

IconData getIconNameFromContentType(ContentType contentType) {
  switch (contentType) {
    case ContentType.Web:
      return Icons.web;
    case ContentType.Text:
      return Icons.text_fields;
    case ContentType.Image:
      return Icons.image;
    case ContentType.Audio:
      return Icons.audiotrack;
    case ContentType.Video:
      return Icons.videocam;
    case ContentType.File:
      return Icons.attach_file;
    case ContentType.Notification:
      return Icons.notifications;
          case ContentType.Task:
      return Icons.assignment;
    default:
      return Icons.error;
  }
}  // getIconNameFromContentType