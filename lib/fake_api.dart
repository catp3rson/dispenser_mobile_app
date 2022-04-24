const duration = Duration(milliseconds: 200);

Future<List<Map<String, dynamic>>> getOrder() => Future.delayed(
    duration,
    () => List.generate(
        8,
        (index) => {
              'uuid': 'uuid_$index',
              'name': 'My order ' + (index + 1).toString(),
              'desc': 'Coke',
            }));

Future<List<Map<String, dynamic>>> getFoodShop() => Future.delayed(
    duration,
    () => List.generate(
        13,
        (i) => {
              'uuid': 'uuid_' + (i + 1).toString(),
              'name': 'Coke ' + (i + 69).toString(),
              'desc': 'Drinks',
            }));

Future<Map<String, dynamic>> getOrderDetail() => Future.delayed(
      duration,
      () => {
        'name': 'My order',
        'item': List.generate(
            15,
            (i) => {
                  'uuid': 'uuid_' + (i + 1).toString(),
                  'name': 'Coke ' + i.toString(),
                  'desc': 'Drinks',
                  'quantity': i + 1,
                })
      },
    );
