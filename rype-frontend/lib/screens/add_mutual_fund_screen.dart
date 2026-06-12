import 'package:flutter/material.dart';

import '../core/services/mutual_fund_service.dart';

class AddMutualFundScreen
    extends StatefulWidget {
  const AddMutualFundScreen({
    super.key,
  });

  @override
  State<AddMutualFundScreen>
      createState() =>
          _AddMutualFundScreenState();
}

class _AddMutualFundScreenState
    extends State<AddMutualFundScreen> {
  final fundNameController =
      TextEditingController();

  final amfiCodeController =
      TextEditingController();

  final unitsController =
      TextEditingController();

  final purchaseNavController =
      TextEditingController();

  final currentNavController =
      TextEditingController();

  Future<void> save() async {
    await MutualFundService()
        .createFund({
      'fundName':
          fundNameController.text,
      'amfiCode':
          amfiCodeController.text,
      'units': double.parse(
        unitsController.text,
      ),
      'purchaseNav':
          double.parse(
        purchaseNavController.text,
      ),
      'currentNav':
          double.parse(
        currentNavController.text,
      ),
    });

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Add Mutual Fund',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller:
                  fundNameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Fund Name',
              ),
            ),

            TextField(
              controller:
                  amfiCodeController,
              decoration:
                  const InputDecoration(
                labelText:
                    'AMFI Code',
              ),
            ),

            TextField(
              controller:
                  unitsController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Units',
              ),
            ),

            TextField(
              controller:
                  purchaseNavController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Purchase NAV',
              ),
            ),

            TextField(
              controller:
                  currentNavController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Current NAV',
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            ElevatedButton(
              onPressed: save,
              child: const Text(
                'Save',
              ),
            ),
          ],
        ),
      ),
    );
  }
}