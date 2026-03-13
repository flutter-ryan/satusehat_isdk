import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:satusehat_isdk/satusehat_isdk.dart';
import 'package:satusehat_isdk_example/models/consent_model.dart' hide Coding;
import 'package:satusehat_isdk_example/models/provenance_model.dart';
import 'dart:ui' as ui;

class DetailSignProvisioning extends StatefulWidget {
  const DetailSignProvisioning({super.key, this.consent});

  final Consent? consent;

  @override
  State<DetailSignProvisioning> createState() => _DetailSignProvisioningState();
}

class _DetailSignProvisioningState extends State<DetailSignProvisioning> {
  late Consent consent;
  bool _isSigning = false;
  bool _isSigned = false;
  ProvenanceModel? provenanceModel;

  @override
  void initState() {
    super.initState();
    consent = widget.consent!;
  }

  void _signing() async {
    final signResource = SignResource();
    final signature = await signResource.signApproval(
      consentModelToJson(consent),
    );
    setState(() {
      provenanceModel = ProvenanceModel(
        resourceType: "Provenance",
        id: "auto",
        target: [
          Target(reference: "Consent/${consent.id}", display: "Consent"),
        ],
        recorded: DateTime.now(),
        agent: [
          Agent(
            who: Target(reference: "", display: "User"),
            role: [
              Role(
                coding: [
                  Coding(
                    system:
                        "http://terminology.hl7.org/CodeSystem/v3-ParticipationType",
                    code: "PART",
                    display: "Participation",
                  ),
                ],
              ),
            ],
          ),
        ],
        signature: [
          Signature(
            type: [
              Type(
                system: "urn:iso-astm:E1762-95:2013",
                code: "1.2.840.10065.1.12.1.7",
                display: "Consent Signature",
              ),
            ],
            when: DateTime.now().toUtc().toIso8601String(),
            who: Target(reference: "", display: "User"),
            targetFormat: "application/fhir+json",
            sigFormat: "application/jose",
            data: signature,
          ),
        ],
      );
      _isSigning = false;
    });
  }

  void rejectConsent() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Signature')),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraint) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    "Consent",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
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
                        child: buildTitleValue('Status', consent.status!),
                      ),
                      Expanded(
                        child: buildTitleValue(
                          'Performer',
                          consent.performer!.first.display ?? "",
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Data: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: -2.0,
                    children: consent.provision!.data!.map<Widget>((data) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(data.reference!.display ?? '')),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  buildTitleValue(
                    'Statement Date',
                    DateFormat('yyyy-MM-dd').format(consent.dateTime!),
                    style: const TextStyle(fontFamily: 'NanumGothicCoding'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Provenance",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (provenanceModel != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align the entire row to the top
                      children: [
                        Expanded(
                          child: buildTitleValue(
                            'Recorded',
                            DateFormat(
                              'yyyy-MM-dd',
                            ).format(provenanceModel!.recorded!),
                            style: const TextStyle(
                              fontFamily: 'NanumGothicCoding',
                            ),
                          ),
                        ),
                        Expanded(
                          child: buildTitleValue(
                            'Signature Format',
                            provenanceModel?.signature!.first.sigFormat ?? "",
                          ),
                        ),
                      ],
                    ),
                    buildTitleValue(
                      "Signature",
                      chunkSplit(
                        provenanceModel?.signature!.first.data ?? "",
                        calculateMaxCharactersPerLine(
                          context,
                          constraint.maxWidth,
                          'A',
                          const TextStyle(
                            fontFamily: 'NanumGothicCoding',
                            fontSize: 14.0,
                          ),
                        ),
                      ).join("\n"),
                      style: const TextStyle(fontFamily: 'NanumGothicCoding'),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    const Text(
                      "No provenance information available. It appears this Consent document has not been signed yet.",
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (!_isSigned && consent.status != "rejected") ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isSigning = true;
                              _isSigned = true;
                            });
                            _signing();
                          },
                          child: const Text("Approve & Sign"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle reject action
                            // rejectConsent();
                          },
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  ] else if (consent.status != "rejected") ...[
                    const Text("This consent document has been signed."),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // _isSigned = true;
                              // approveConsentJWS();
                            });
                            // _confirmRevoke();
                            // Handle approve action
                          },
                          child: const Text("Revoke Consent"),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isSigning)
            Container(
              decoration: BoxDecoration(color: Colors.black54),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
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

  List<String> chunkSplit(String text, int chunkSize) {
    List<String> chunks = [];
    for (var i = 0; i < text.length; i += chunkSize) {
      int endIndex = i + chunkSize;
      if (endIndex > text.length) endIndex = text.length;
      chunks.add(text.substring(i, endIndex));
    }
    return chunks;
  }

  int calculateMaxCharactersPerLine(
    BuildContext context,
    double availableWidth,
    String character,
    TextStyle textStyle,
  ) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;

    double paddingLeft = MediaQuery.of(context).padding.left;
    double paddingRight = MediaQuery.of(context).padding.right;

    // Subtract padding (left and right)
    availableWidth = screenWidth - 48 - paddingRight - paddingLeft;

    // Create a TextPainter to measure the width of a character
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: character, style: textStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    // Get the width of the character
    double charWidth = textPainter.size.width;

    // Calculate how many characters fit in the device width
    int maxCharacters = (availableWidth / charWidth).floor();

    return maxCharacters;
  }
}
