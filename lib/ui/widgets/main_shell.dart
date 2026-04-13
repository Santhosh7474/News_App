import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'modern_bottom_nav.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The current active page
          navigationShell,

          // Modern Floating Animated Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ModernBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              icons: const [
                CupertinoIcons.house_alt,
                CupertinoIcons.search,
                CupertinoIcons.person,
              ],
              activeIcons: const [
                CupertinoIcons.house_fill,
                CupertinoIcons.search,
                CupertinoIcons.person_solid,
              ],
              onTap: (index) => _onTap(context, index),
            ),
          ),
        ],
      ),
    );
  }
}



class AnimatedBranchContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<AnimatedBranchContainer> createState() => _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer> {
  int _currentIndex = 0;
  int _previousIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() {
        _previousIndex = oldWidget.currentIndex;
        _currentIndex = widget.currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (index) {
        final isActive = index == _currentIndex;
        final isPrevious = index == _previousIndex;
        // Keep active or animating-out branches alive inside the tree.
        final shouldRender = isActive || isPrevious;

        return Offstage(
          offstage: !shouldRender,
          child: TickerMode(
            enabled: shouldRender,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              opacity: isActive ? 1.0 : 0.0,
              onEnd: () {
                if (!isActive && isPrevious && mounted) {
                  setState(() {
                    _previousIndex = -1; // Animation finished, remove from layout cleanly
                  });
                }
              },
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                scale: isActive ? 1.0 : 0.95,
                child: widget.children[index],
              ),
            ),
          ),
        );
      }),
    );
  }
}
