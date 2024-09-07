import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GenericErrorWidget extends StatelessWidget {
  final Function onRefresh;

  const GenericErrorWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return _NoContentWidget(
        onRefresh: onRefresh,
        icon: Icons.error_outline_rounded,
        text: 'something went wrong');
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final Function onRefresh;

  const NetworkErrorWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return _NoContentWidget(
        onRefresh: onRefresh,
        icon: Icons.wifi_off_rounded,
        text: 'no internet');
  }
}

class EmptyWidget extends StatelessWidget {
  final Function onRefresh;
  final String? refreshButtonText;
  final String? text;
  final bool allowRefresh;

  const EmptyWidget(
      {super.key,
      required this.onRefresh,
      this.text,
      this.refreshButtonText,
      this.allowRefresh = true});

  @override
  Widget build(BuildContext context) {
    return _NoContentWidget(
      onRefresh: onRefresh,
      icon: Icons.hourglass_empty_rounded,
      text: text ?? 'no content',
      refreshButtonText: refreshButtonText,
      allowRefresh: allowRefresh,
    );
  }
}

class _NoContentWidget extends StatelessWidget {
  final Function onRefresh;
  final IconData icon;
  final String text;
  final String? refreshButtonText;
  final bool allowRefresh;

  const _NoContentWidget(
      {required this.onRefresh,
      required this.icon,
      required this.text,
      this.allowRefresh = true,
      this.refreshButtonText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 96),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          if (allowRefresh) ...[
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () {
                  onRefresh();
                },
                child: Text(
                  refreshButtonText ?? 'refresh'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.blue),
                ))
          ]
        ],
      ),
    );
  }
}
