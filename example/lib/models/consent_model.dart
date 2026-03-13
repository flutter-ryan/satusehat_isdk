import 'dart:convert';

ConsentModel consentModelFromJson(String str) =>
    ConsentModel.fromJson(json.decode(str));

String consentModelToJson(Consent data) => json.encode(data.toJson());

class ConsentModel {
  List<Consent>? entry;
  String? resourceType;
  String? type;

  ConsentModel({this.entry, this.resourceType, this.type});

  factory ConsentModel.fromJson(Map<String, dynamic> json) => ConsentModel(
    entry: json["entry"] == null
        ? []
        : List<Consent>.from(json["entry"]!.map((x) => Consent.fromJson(x))),
    resourceType: json["resourceType"],
    type: json["type"],
  );
}

class Consent {
  String? id;
  List<PolicyRule>? category;
  DateTime? dateTime;
  String? entryId;
  List<Organization>? organization;
  Patient? patient;
  List<Organization>? performer;
  PolicyRule? policyRule;
  Provision? provision;
  String? resourceType;
  PolicyRule? scope;
  String? status;

  Consent({
    this.id,
    this.category,
    this.dateTime,
    this.entryId,
    this.organization,
    this.patient,
    this.performer,
    this.policyRule,
    this.provision,
    this.resourceType,
    this.scope,
    this.status,
  });

  factory Consent.fromJson(Map<String, dynamic> json) => Consent(
    id: json["_id"],
    category: json["category"] == null
        ? []
        : List<PolicyRule>.from(
            json["category"]!.map((x) => PolicyRule.fromJson(x)),
          ),
    dateTime: json["dateTime"] == null
        ? null
        : DateTime.parse(json["dateTime"]),
    entryId: json["id"],
    organization: json["organization"] == null
        ? []
        : List<Organization>.from(
            json["organization"]!.map((x) => Organization.fromJson(x)),
          ),
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    performer: json["performer"] == null
        ? []
        : List<Organization>.from(
            json["performer"]!.map((x) => Organization.fromJson(x)),
          ),
    policyRule: json["policyRule"] == null
        ? null
        : PolicyRule.fromJson(json["policyRule"]),
    provision: json["provision"] == null
        ? null
        : Provision.fromJson(json["provision"]),
    resourceType: json["resourceType"],
    scope: json["scope"] == null ? null : PolicyRule.fromJson(json["scope"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "category": category == null
        ? []
        : List<dynamic>.from(category!.map((x) => x.toJson())),
    "dateTime": dateTime?.toIso8601String(),
    "id": entryId,
    "organization": organization == null
        ? []
        : List<dynamic>.from(organization!.map((x) => x.toJson())),
    "patient": patient?.toJson(),
    "performer": performer == null
        ? []
        : List<dynamic>.from(performer!.map((x) => x.toJson())),
    "policyRule": policyRule?.toJson(),
    "provision": provision?.toJson(),
    "resourceType": resourceType,
    "scope": scope?.toJson(),
    "status": status,
  };
}

class PolicyRule {
  List<Coding>? coding;

  PolicyRule({this.coding});

  factory PolicyRule.fromJson(Map<String, dynamic> json) => PolicyRule(
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
  String? code;
  String? display;
  String? system;

  Coding({this.code, this.display, this.system});

  factory Coding.fromJson(Map<String, dynamic> json) => Coding(
    code: json["code"],
    display: json["display"],
    system: json["system"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "display": display,
    "system": system,
  };
}

class Organization {
  String? display;
  String? reference;

  Organization({this.display, this.reference});

  factory Organization.fromJson(Map<String, dynamic> json) =>
      Organization(display: json["display"], reference: json["reference"]);

  Map<String, dynamic> toJson() => {"display": display, "reference": reference};
}

class Patient {
  String? reference;

  Patient({this.reference});

  factory Patient.fromJson(Map<String, dynamic> json) =>
      Patient(reference: json["reference"]);

  Map<String, dynamic> toJson() => {"reference": reference};
}

class Provision {
  List<PolicyRule>? action;
  List<Actor>? actor;
  List<Datum>? data;
  Period? period;
  String? type;

  Provision({this.action, this.actor, this.data, this.period, this.type});

  factory Provision.fromJson(Map<String, dynamic> json) => Provision(
    action: json["action"] == null
        ? []
        : List<PolicyRule>.from(
            json["action"]!.map((x) => PolicyRule.fromJson(x)),
          ),
    actor: json["actor"] == null
        ? []
        : List<Actor>.from(json["actor"]!.map((x) => Actor.fromJson(x))),
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    period: json["period"] == null ? null : Period.fromJson(json["period"]),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "action": action == null
        ? []
        : List<dynamic>.from(action!.map((x) => x.toJson())),
    "actor": actor == null
        ? []
        : List<dynamic>.from(actor!.map((x) => x.toJson())),
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "period": period?.toJson(),
    "type": type,
  };

  // Function to search for actors with specific role.coding.system and role.coding.code
  List<Actor> getActorsByRole(String system, String code) {
    List<Actor> matchingActors = [];

    if (actor!.isNotEmpty) {
      for (var actor in actor!) {
        for (var coding in actor.role!.coding!) {
          if (coding.system == system && coding.code == code) {
            matchingActors.add(actor);
            break; // Found a matching coding, move to the next actor
          }
        }
      }
    }

    return matchingActors;
  }
}

class Actor {
  Organization? reference;
  PolicyRule? role;

  Actor({this.reference, this.role});

  factory Actor.fromJson(Map<String, dynamic> json) => Actor(
    reference: json["reference"] == null
        ? null
        : Organization.fromJson(json["reference"]),
    role: json["role"] == null ? null : PolicyRule.fromJson(json["role"]),
  );

  Map<String, dynamic> toJson() => {
    "reference": reference?.toJson(),
    "role": role?.toJson(),
  };
}

class Datum {
  String? meaning;
  Organization? reference;

  Datum({this.meaning, this.reference});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    meaning: json["meaning"],
    reference: json["reference"] == null
        ? null
        : Organization.fromJson(json["reference"]),
  );

  Map<String, dynamic> toJson() => {
    "meaning": meaning,
    "reference": reference?.toJson(),
  };
}

class Period {
  DateTime? end;
  DateTime? start;

  Period({this.end, this.start});

  factory Period.fromJson(Map<String, dynamic> json) => Period(
    end: json["end"] == null ? null : DateTime.parse(json["end"]),
    start: json["start"] == null ? null : DateTime.parse(json["start"]),
  );

  Map<String, dynamic> toJson() => {
    "end": end?.toIso8601String(),
    "start": start?.toIso8601String(),
  };
}
