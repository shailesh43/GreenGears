import 'package:flutter/material.dart';
import 'package:greengears/network/api_models/car_request.dart';
import '../../custom/widgets/request_card.dart';
import '../../custom/modals/delete_request_modal.dart';

class ActiveRequestPage extends StatefulWidget {
  final CarRequest request;

  const ActiveRequestPage({
    super.key,
    required this.request,
  });

  @override
  State<ActiveRequestPage> createState() => _ActiveRequestPageState();
}

class _ActiveRequestPageState extends State<ActiveRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Vehicle Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RequestCard(
          request: widget.request,
          onTap: () {
            _showDeleteRequestModal(context, widget.request);
          },
        ),
      ),
    );
  }

  void _showDeleteRequestModal(BuildContext context, CarRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteRequestModal(request: request),
    );
  }

}
