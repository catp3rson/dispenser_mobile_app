const duration = Duration(milliseconds: 200);

Future<List<Map<String, dynamic>>> getOrder() => Future.delayed(
    duration,
    () => List.generate(
        8,
        (index) => {
              'name': 'My order ' + (index + 1).toString(),
              'desc': 'Coke',
            }));

Future<List<Map<String, dynamic>>> getFoodShop() => Future.delayed(
    duration,
    () => List.generate(
        13,
        (i) => {
              'name': 'Coke ' + (i + 69).toString(),
              'desc': 'Drinks',
            }));

Future<List<Map<String, dynamic>>> getFoodOrder() => Future.delayed(
    duration,
    () => List.generate(
        15,
        (i) => {
              'name': 'Coke ' + i.toString(),
              'desc': 'Drinks',
              'quantity': i + 1,
            }));
