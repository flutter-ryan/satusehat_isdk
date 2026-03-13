import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:satusehat_isdk_example/detail_sign_provisioning.dart';
import 'package:satusehat_isdk_example/models/consent_model.dart';

class SignProvisioning extends StatefulWidget {
  const SignProvisioning({super.key});

  @override
  State<SignProvisioning> createState() => _SignProvisioningState();
}

class _SignProvisioningState extends State<SignProvisioning> {
  List<Consent> _datas = [];

  @override
  void initState() {
    super.initState();
    _getDataJson();
  }

  Future<void> _getDataJson() async {
    final jsonString = await rootBundle.loadString('docs/consent.json');
    final data = consentModelFromJson(jsonString);
    setState(() {
      _datas = data.entry!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Provisioning')),
      body: _datas.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _datas.length,
              itemBuilder: (context, index) {
                final consent = _datas[index];

                final actors = consent.provision!.getActorsByRole(
                  'http://terminology.hl7.org/CodeSystem/v3-ParticipationType',
                  'PRCP',
                );
                final actorNames = actors
                    .map((actor) => actor.reference!.display ?? '')
                    .join(', ');

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailSignProvisioning(consent: consent),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: 0,
                    ),
                    elevation: 2, // Elevation for shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        bottom: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTitleValue("Consent ID", consent.id!),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align the entire row to the top
                            children: [
                              Expanded(
                                child: buildTitleValue(
                                  'Scope',
                                  consent.scope!.coding!.first.display!,
                                ),
                              ),
                              Expanded(
                                child: buildTitleValue(
                                  'Provision Type',
                                  consent.provision!.type!,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align the entire row to the top
                            children: [
                              Expanded(
                                child: buildTitleValue(
                                  'Category',
                                  consent
                                      .category!
                                      .first
                                      .coding!
                                      .first
                                      .display!,
                                ),
                              ),
                              Expanded(
                                child: buildTitleValue(
                                  'Statement Date',
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(consent.dateTime!),
                                  style: const TextStyle(
                                    fontFamily: 'NanumGothicCoding',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          buildTitleValue('Primary Recipient', actorNames),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget buildTitleValue(String title, String value, {TextStyle? style}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          value,
          style: style,
          softWrap: true,
          overflow: TextOverflow.visible, // Ensure the text breaks visibly
          textWidthBasis: TextWidthBasis.longestLine,
        ),
        const SizedBox(height: 10), // Spacing between title-value pairs
      ],
    );
  }
}
