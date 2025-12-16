import 'package:flutter/material.dart';
import '../data/material_cost.dart';
//import '../models/material_cost.dart';   // adjust path based on your project

class MaterialCostTable extends StatefulWidget {
  final List<MaterialCost> items;
  final Function(List<MaterialCost>) onChanged;
  final String? caption;

  const MaterialCostTable({
    super.key,
    required this.items,
    required this.onChanged,
    this.caption,
  });

  @override
  State<MaterialCostTable> createState() => _MaterialCostTableState();
}

class _MaterialCostTableState extends State<MaterialCostTable> {
  final List<Unit> units = [Unit.piece, Unit.kg, Unit.liter];

  void addItem() {
    setState(() {
      widget.items.add(MaterialCost(
        item: "",
        quantity: 0,
        unit: Unit.piece,
        unitCost: 0,
      ));
    });
    widget.onChanged(widget.items);
  }

  void removeItem(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
    widget.onChanged(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.caption != null) ...[
          Text(
            widget.caption!,
            style: const TextStyle(
              fontSize: 16,
              //fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        // ---------- TABLE HEADERS ----------
        Row(
          children: const [
            Expanded(
                child: Text("Item",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            Expanded(
                child:
                    Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            Expanded(
                child: Text("Unit",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            Expanded(
                child: Text("Unit Cost",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            Expanded(
                child: Text("Total",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 8),

        // ---------- ITEM ROWS ----------
        Column(
          children: List.generate(widget.items.length, (index) {
            final material = widget.items[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  // ITEM NAME
                  Expanded(
                    child: TextFormField(
                      initialValue: material.item,
                      decoration: const InputDecoration(
                        labelText: "Item",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        material.item = v;
                        widget.onChanged(widget.items);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // QUANTITY
                  Expanded(
                    child: TextFormField(
                      initialValue: material.quantity?.toString() ?? "0",
                      decoration: const InputDecoration(
                        labelText: "Qty",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        material.quantity = double.tryParse(v) ?? 0.0;
                        setState(() {});
                        widget.onChanged(widget.items);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // UNIT DROPDOWN
                  Expanded(
                    child: DropdownButtonFormField<Unit>(
                      value: material.unit,
                      decoration: const InputDecoration(
                        labelText: "Unit",
                        border: OutlineInputBorder(),
                      ),
                      items: units.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text(unitToString(u)),
                        );
                      }).toList(),
                      onChanged: (u) {
                        material.unit = u!;
                        widget.onChanged(widget.items);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // UNIT COST
                  Expanded(
                    child: TextFormField(
                      initialValue: material.unitCost?.toString() ?? "0",
                      decoration: const InputDecoration(
                        labelText: "Unit Cost",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        material.unitCost = double.tryParse(v) ?? 0.0;
                        setState(() {});
                        widget.onChanged(widget.items);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // TOTAL (READ-ONLY)
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: ((material.quantity ?? 0) *
                                (material.unitCost ?? 0))
                            .toString(),
                      ),
                      decoration: const InputDecoration(
                        labelText: "Total",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeItem(index),
                  ),
                ],
              ),
            );
          }),
        ),

        // ---------- ADD BUTTON ----------
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: addItem,
            child: const Text("+ Add Item"),
          ),
        ),
      ],
    );
  }
}
