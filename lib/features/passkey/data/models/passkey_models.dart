class PasskeyRelyingParty {
  final String id;
  final String name;

  const PasskeyRelyingParty({
    required this.id,
    required this.name,
  });

  factory PasskeyRelyingParty.fromJson(Map<String, dynamic> json) {
    return PasskeyRelyingParty(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class PasskeyUser {
  final String id;
  final String name;
  final String displayName;

  const PasskeyUser({
    required this.id,
    required this.name,
    required this.displayName,
  });

  factory PasskeyUser.fromJson(Map<String, dynamic> json) {
    return PasskeyUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
    );
  }
}

class PasskeyCredentialDescriptor {
  final String type;
  final String id;
  final List<String> transports;

  const PasskeyCredentialDescriptor({
    required this.type,
    required this.id,
    required this.transports,
  });

  factory PasskeyCredentialDescriptor.fromJson(Map<String, dynamic> json) {
    return PasskeyCredentialDescriptor(
      type: json['type']?.toString() ?? 'public-key',
      id: json['id']?.toString() ?? '',
      transports: (json['transports'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class PasskeyPubKeyParam {
  final String type;
  final int alg;

  const PasskeyPubKeyParam({
    required this.type,
    required this.alg,
  });

  factory PasskeyPubKeyParam.fromJson(Map<String, dynamic> json) {
    return PasskeyPubKeyParam(
      type: json['type']?.toString() ?? 'public-key',
      alg: json['alg'] is int
          ? json['alg'] as int
          : int.tryParse(json['alg']?.toString() ?? '') ?? -7,
    );
  }
}

class PasskeyAttestationOptions {
  final String challenge;
  final PasskeyRelyingParty rp;
  final PasskeyUser user;
  final int? timeout;
  final String? attestation;
  final Map<String, dynamic>? authenticatorSelection;
  final List<PasskeyCredentialDescriptor> excludeCredentials;
  final List<PasskeyPubKeyParam> pubKeyCredParams;

  const PasskeyAttestationOptions({
    required this.challenge,
    required this.rp,
    required this.user,
    required this.excludeCredentials,
    required this.pubKeyCredParams,
    this.timeout,
    this.attestation,
    this.authenticatorSelection,
  });

  factory PasskeyAttestationOptions.fromJson(Map<String, dynamic> json) {
    final rpJson = json['rp'] as Map<String, dynamic>? ?? const {};
    final userJson = json['user'] as Map<String, dynamic>? ?? const {};

    return PasskeyAttestationOptions(
      challenge: json['challenge']?.toString() ?? '',
      rp: PasskeyRelyingParty.fromJson(rpJson),
      user: PasskeyUser.fromJson(userJson),
      timeout: json['timeout'] is int ? json['timeout'] as int : null,
      attestation: json['attestation']?.toString(),
      authenticatorSelection:
          json['authenticatorSelection'] as Map<String, dynamic>?,
      excludeCredentials: (json['excludeCredentials'] as List?)
              ?.map((e) =>
                  PasskeyCredentialDescriptor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pubKeyCredParams: (json['pubKeyCredParams'] as List?)
              ?.map(
                  (e) => PasskeyPubKeyParam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class PasskeyAssertionOptions {
  final String challenge;
  final String rpId;
  final int? timeout;
  final String? userVerification;
  final List<PasskeyCredentialDescriptor> allowCredentials;

  const PasskeyAssertionOptions({
    required this.challenge,
    required this.rpId,
    required this.allowCredentials,
    this.timeout,
    this.userVerification,
  });

  factory PasskeyAssertionOptions.fromJson(Map<String, dynamic> json) {
    final rpMap = json['rp'] as Map<String, dynamic>?;
    return PasskeyAssertionOptions(
      challenge: json['challenge']?.toString() ?? '',
      rpId: json['rpId']?.toString() ?? rpMap?['id']?.toString() ?? '',
      timeout: json['timeout'] is int ? json['timeout'] as int : null,
      userVerification: json['userVerification']?.toString(),
      allowCredentials: (json['allowCredentials'] as List?)
              ?.map((e) =>
                  PasskeyCredentialDescriptor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
