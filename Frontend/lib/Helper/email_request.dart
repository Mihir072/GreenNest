class EmailRequest {
  final String toEmail;
  final String subject;
  final String message;

  EmailRequest({
    required this.toEmail,
    required this.subject,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'toEmail': toEmail,
        'subject': subject,
        'message': message,
      };
}
