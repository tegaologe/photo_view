import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view_example/screens/common/app_bar.dart';
import 'package:photo_view_example/screens/examples/gallery/gallery_example_item.dart';

class GalleryExample extends StatefulWidget {
  const GalleryExample({super.key});

  @override
  State<GalleryExample> createState() => _GalleryExampleState();
}

class _GalleryExampleState extends State<GalleryExample> {
  bool verticalGallery = false;

  @override
  Widget build(BuildContext context) {
    return ExampleAppBarLayout(
      title: "Gallery Example",
      showGoBack: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GalleryExampleItemThumbnail(
                  galleryExampleItem: galleryItems[0],
                  onTap: () {
                    open(context, 0);
                  },
                ),
                GalleryExampleItemThumbnail(
                  galleryExampleItem: galleryItems[2],
                  onTap: () {
                    open(context, 2);
                  },
                ),
                GalleryExampleItemThumbnail(
                  galleryExampleItem: galleryItems[3],
                  onTap: () {
                    open(context, 3);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Vertical"),
                Checkbox(
                  value: verticalGallery,
                  onChanged: (value) {
                    setState(() {
                      verticalGallery = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void open(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: galleryItems,
          initialIndex: index,
          scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
        ),
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    super.key,
    this.loadingBuilder,
    this.backgroundDecoration = const BoxDecoration(color: Color(0xff000000)),
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final PhotoViewImageLoadingBuilder? loadingBuilder;
  final BoxDecoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<GalleryExampleItem> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            PhotoViewGallery(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Image ${currentIndex + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = widget.galleryItems[index];
    return item.isSvg
        ? PhotoView.custom(
            childSize: const Size(300, 300),
            minScale: const PhotoViewScale.contained() * (0.5 + index / 10),
            maxScale: const PhotoViewScale.covered() * 4.1,
            decoration: PhotoViewDecoration(
              heroAttributes: PhotoViewHeroAttributes(tag: item.id),
              backgroundDecoration: widget.backgroundDecoration,
            ),
            child: SizedBox(
              width: 300,
              height: 300,
              child: SvgPicture.asset(item.resource, height: 200.0),
            ),
          )
        : PhotoView(
            imageProvider: AssetImage(item.resource),
            minScale: const PhotoViewScale.contained() * (0.5 + index / 10),
            maxScale: const PhotoViewScale.covered() * 4.1,
            loadingBuilder:
                widget.loadingBuilder ?? (_, __) => const SizedBox(),
            decoration: PhotoViewDecoration(
              heroAttributes: PhotoViewHeroAttributes(tag: item.id),
              backgroundDecoration: widget.backgroundDecoration,
            ),
          );
  }
}
