import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import '../data/filters.dart';
import '../models/photo_filter.dart';
import '../painting/filter_renderer.dart';
import '../widgets/filter_picker.dart';
import '../widgets/filtered_view.dart';

/// 촬영한 사진을 보여 준다. 사용자는 필터를 고르고 사진을 저장한다.
///
/// 저장할 때 원본과 필터 적용본을 함께 사진 보관함에 저장한다.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.image, required this.noise});

  /// 필터 적용 전의 기준 이미지. 이 화면이 닫힐 때 해제한다.
  final ui.Image image;
  final ui.Image? noise;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  FilterCategory _category = FilterCategory.basic;
  PhotoFilter _filter = original;
  bool _saving = false;

  @override
  void dispose() {
    widget.image.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('사진 보관함 권한이 없습니다. 설정에서 권한을 허용하십시오.')),
          );
          return;
        }
      }
      final stamp = DateTime.now().millisecondsSinceEpoch;
      // 원본을 먼저 저장한다. 필터 적용본의 저장이 실패해도 원본은 남는다.
      await Gal.putImageBytes(
        await encodeJpeg(widget.image),
        name: 'mangcut_${stamp}_original',
      );
      final filter = _filter;
      if (filter != original) {
        final rendered = await renderFiltered(
          widget.image,
          filter,
          widget.noise,
        );
        try {
          await Gal.putImageBytes(
            await encodeJpeg(rendered),
            name: 'mangcut_${stamp}_${filter.id}',
          );
        } finally {
          rendered.dispose();
        }
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            filter == original ? '원본을 저장했습니다.' : '원본과 필터 적용본을 저장했습니다.',
          ),
        ),
      );
    } on GalException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('사진을 저장하지 못했습니다. (${e.type.message})')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('사진을 저장하지 못했습니다. ($e)')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.image.width / widget.image.height,
                  child: FilteredView(
                    filter: _filter,
                    noise: widget.noise,
                    child: RawImage(image: widget.image, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilterPicker(
              filters: filters,
              category: _category,
              selected: _filter,
              onCategoryChanged: (c) => setState(() => _category = c),
              onSelected: (f) => setState(() => _filter = f),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('다시 찍기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('저장'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
