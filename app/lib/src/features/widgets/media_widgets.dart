import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    this.size = 56,
    this.borderRadius = 14,
  });

  final String? url;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallback = _FallbackCover(radius: borderRadius);

    if (url == null || url!.isEmpty) {
      return SizedBox(width: size, height: size, child: fallback);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          width: size,
          height: size,
          color: AppColors.surfaceVariant,
        ),
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.dark],
        ),
      ),
      child: const Icon(Icons.self_improvement, color: Colors.white70),
    );
  }
}

class ArtistCircle extends StatelessWidget {
  const ArtistCircle({
    super.key,
    required this.photoUrl,
    required this.name,
    this.size = 64,
  });

  final String? photoUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.characters.first : '◌';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryContainer,
            border: Border.all(color: AppColors.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: photoUrl == null || photoUrl!.isEmpty
              ? Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: photoUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size + 12,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
