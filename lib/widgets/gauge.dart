import 'package:flutter/material.dart';

class SimpleGauge extends StatefulWidget {
  final double value; // 0..1
  final String label;
  final String subtitle;
  final Color color;

  const SimpleGauge(
      {required this.value,
      required this.label,
      required this.subtitle,
      required this.color,
      super.key});

  @override
  State<SimpleGauge> createState() => _SimpleGaugeState();
}

class _SimpleGaugeState extends State<SimpleGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = Tween<double>(begin: 0, end: widget.value)
        .animate(CurvedAnimation(parent: _ctl, curve: Curves.easeOut));
    _ctl.forward();
  }

  @override
  void didUpdateWidget(covariant SimpleGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _anim = Tween<double>(begin: _anim.value, end: widget.value)
        .animate(CurvedAnimation(parent: _ctl, curve: Curves.easeOut));
    _ctl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final percent = (_anim.value * 100).toStringAsFixed(0);
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2)),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                        height: 10,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6))),
                    FractionallySizedBox(
                      widthFactor: _anim.value,
                      child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(6))),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    Text("$percent%",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: widget.color)),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
