import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  NumberTriviaPage({super.key});
  
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var controller = context.read<NumberTriviaBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder(
              bloc: controller,
              builder: (context, state) {
                if (state is Loading) {
                  return const CupertinoActivityIndicator();
                }
        
                if (state is Loaded) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.numberTrivia.number.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(state.numberTrivia.text),
                    ],
                  );
                }
        
                if (state is Error) {
                  return Text(state.message);
                }
        
                return const SizedBox();
              },
            ),
        
        
            TextFormField(
              controller: _textEditingController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.add(GetTriviaForConcreteNumber(_textEditingController.text));
                    _textEditingController.clear();
                  },
                  child: const Text('Get Trivia')
                ),
                const SizedBox(width: 64,),
                ElevatedButton(
                  onPressed: () => controller.add(GetTriviaForRandomNumber()), 
                  child: const Text('Get Random Trivia')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}