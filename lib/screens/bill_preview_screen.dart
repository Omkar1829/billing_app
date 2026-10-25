import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/bill_image_generator.dart';
import '../services/storage_service.dart';
import '../widgets/bill_document_widget.dart';
import '../widgets/glass_card.dart';

class BillPreviewScreen extends StatefulWidget {
  final BillModel bill;
  final bool autoSave;

  const BillPreviewScreen({
    super.key,
    required this.bill,
    this.autoSave = true,
  });

  @override
  State<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends State<BillPreviewScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoSave) {
      _saveBillSilently();
    }
  }

  Future<void> _saveBillSilently() async {
    await StorageService.saveBill(widget.bill);
  }

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);
    try {
      final pngBytes = await BillImageGenerator.capturePng(_repaintBoundaryKey, pixelRatio: 3.5);
      if (pngBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate PNG image. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final file = await BillImageGenerator.savePngToTemp(pngBytes, widget.bill);
      await BillImageGenerator.shareBillPng(file, widget.bill);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing bill: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: Text('Bill #${widget.bill.billNo} Preview'),
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Share PNG',
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.share_rounded),
            onPressed: _isSharing ? null : _handleShare,
          ),
        ],
      ),
      body: Column(
        children: [
          // Frosted Glass Hint Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pinch_rounded, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  'Pinch or drag to zoom bill details',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.5),
                ),
              ],
            ),
          ),

          // Zoomable Document Canvas with Glass Ambient Background
          Expanded(
            child: InteractiveViewer(
              minScale: 0.4,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(40),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                            blurRadius: 40,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: BillDocumentWidget(
                        bill: widget.bill,
                        width: 720,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Glass Dock
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              borderRadius: 20,
              opacity: 0.12,
              padding: const EdgeInsets.all(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.edit_note_rounded, size: 20),
                      label: const Text('Edit Fields'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSharing ? null : _handleShare,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded, size: 20),
                      label: Text(
                        _isSharing ? 'Generating PNG...' : 'Share Bill PNG',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
