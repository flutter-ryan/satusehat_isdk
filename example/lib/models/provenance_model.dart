import 'dart:convert';

ProvenanceModel provenanceModelFromJson(String str) =>
    ProvenanceModel.fromJson(json.decode(str));

String provenanceModelToJson(ProvenanceModel data) =>
    json.encode(data.toJson());

class ProvenanceModel {
  String? resourceType;
  String? id;
  List<Target>? target;
  DateTime? recorded;
  List<Agent>? agent;
  List<Signature>? signature;

  ProvenanceModel({
    this.resourceType,
    this.id,
    this.target,
    this.recorded,
    this.agent,
    this.signature,
  });

  factory ProvenanceModel.fromJson(Map<String, dynamic> json) =>
      ProvenanceModel(
        resourceType: json["resourceType"],
        id: json["id"],
        target: json["target"] == null
            ? []
            : List<Target>.from(json["target"]!.map((x) => Target.fromJson(x))),
        recorded: json["recorded"] == null
            ? null
            : DateTime.parse(json["recorded"]),
        agent: json["agent"] == null
            ? []
            : List<Agent>.from(json["agent"]!.map((x) => Agent.fromJson(x))),
        signature: json["signature"] == null
            ? []
            : List<Signature>.from(
                json["signature"]!.map((x) => Signature.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "resourceType": resourceType,
    "id": id,
    "target": target == null
        ? []
        : List<dynamic>.from(target!.map((x) => x.toJson())),
    "recorded": recorded?.toIso8601String(),
    "agent": agent == null
        ? []
        : List<dynamic>.from(agent!.map((x) => x.toJson())),
    "signature": signature == null
        ? []
        : List<dynamic>.from(signature!.map((x) => x.toJson())),
  };
}

class Agent {
  List<Role>? role;
  Target? who;

  Agent({this.role, this.who});

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
    role: json["role"] == null
        ? []
        : List<Role>.from(json["role"]!.map((x) => Role.fromJson(x))),
    who: json["who"] == null ? null : Target.fromJson(json["who"]),
  );

  Map<String, dynamic> toJson() => {
    "role": role == null
        ? []
        : List<dynamic>.from(role!.map((x) => x.toJson())),
    "who": who?.toJson(),
  };
}

class Role {
  List<Coding>? coding;

  Role({this.coding});

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    coding: json["coding"] == null
        ? []
        : List<Coding>.from(json["coding"]!.map((x) => Coding.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "coding": coding == null
        ? []
        : List<dynamic>.from(coding!.map((x) => x.toJson())),
  };
}

class Coding {
  String? system;
  String? code;
  String? display;

  Coding({this.system, this.code, this.display});

  factory Coding.fromJson(Map<String, dynamic> json) => Coding(
    system: json["system"],
    code: json["code"],
    display: json["display"],
  );

  Map<String, dynamic> toJson() => {
    "system": system,
    "code": code,
    "display": display,
  };
}

class Target {
  String? reference;
  String? display;

  Target({this.reference, this.display});

  factory Target.fromJson(Map<String, dynamic> json) =>
      Target(reference: json["reference"], display: json["display"]);

  Map<String, dynamic> toJson() => {"reference": reference, "display": display};
}

class Signature {
  List<Type>? type;
  String? when;
  Target? who;
  String? targetFormat;
  String? sigFormat;
  String? data;

  Signature({
    this.type,
    this.when,
    this.who,
    this.targetFormat,
    this.sigFormat,
    this.data,
  });

  factory Signature.fromJson(Map<String, dynamic> json) => Signature(
    type: json["type"] == null
        ? []
        : List<Type>.from(json["type"]!.map((x) => Type.fromJson(x))),
    when: json["when"],
    who: json["who"] == null ? null : Target.fromJson(json["who"]),
    targetFormat: json["targetFormat"],
    sigFormat: json["sigFormat"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "type": type == null
        ? []
        : List<dynamic>.from(type!.map((x) => x.toJson())),
    "when": when,
    "who": who?.toJson(),
    "targetFormat": targetFormat,
    "sigFormat": sigFormat,
    "data": data,
  };
}

class Type {
  String? system;
  String? code;
  String? display;

  Type({this.system, this.code, this.display});

  factory Type.fromJson(Map<String, dynamic> json) => Type(
    system: json["system"],
    code: json["code"],
    display: json["display"],
  );

  Map<String, dynamic> toJson() => {
    "system": system,
    "code": code,
    "display": display,
  };
}
