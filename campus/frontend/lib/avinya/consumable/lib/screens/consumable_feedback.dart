import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

class ConsumableFeedbackScreen extends StatefulWidget {
  const ConsumableFeedbackScreen({Key? key}) : super(key: key);

  @override
  _ConsumableFeedbackScreenState createState() =>
      _ConsumableFeedbackScreenState();
}

class _ConsumableFeedbackScreenState extends State<ConsumableFeedbackScreen>
    with SingleTickerProviderStateMixin {
  var _ratingPageController = PageController();

  @override
  Widget build(BuildContext context) => Container(
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   'Breakfast Menu',
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 18.0,
              //   ),
              // ),
              SizedBox(height: 8.0),
              SizedBox(
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Container(
                      padding: EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                              height: 300,
                              child: PageView(
                                controller: _ratingPageController,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  _buildThanksNote(),
                                  _causeOfRating(),
                                ],
                              )),
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.red,
                                child: MaterialButton(
                                  onPressed: () {
                                    _ratingPageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeIn);
                                  },
                                  child: Text('Done'),
                                  textColor: Colors.white,
                                ),
                              ))
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      );
}

_buildThanksNote() => Container(
      child: Column(
        children: [
          Text('Thanks for your feedback'),
          Text('How was your experience?'),
          Row(
            children: [
              for (var i in range(5))
                IconButton(
                  onPressed: () {
                    // _ratingPageController.nextPage(
                    //     duration: Duration(milliseconds: 300),
                    //     curve: Curves.easeIn);
                  },
                  icon: Icon(Icons.star),
                )
            ],
          )
        ],
      ),
    );

_causeOfRating() => Container(
      child: Column(
        children: [
          Text('What was the cause of your rating?'),
          Row(
            children: [
              for (var i in range(5))
                IconButton(
                  onPressed: () {
                    // _ratingPageController.previousPage(
                    //     duration: Duration(milliseconds: 300),
                    //     curve: Curves.easeIn);
                  },
                  icon: Icon(Icons.star),
                )
            ],
          )
        ],
      ),
    );
