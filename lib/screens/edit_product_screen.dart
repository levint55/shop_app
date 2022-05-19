import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  bool _isInit = true;
  Product _product =
      Product(id: "", title: "", description: "", price: 0, imageUrl: "");
  var _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImgUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImgUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      String productId = ModalRoute.of(context)?.settings.arguments as String;
      if (productId != '') {
        _product =
            Provider.of<Products>(context, listen: false).findById(productId);

        _initValue = {
          'title': _product.title,
          'description': _product.description,
          'price': _product.price.toString(),
          'imageUrl': ''
        };

        _imageUrlController.text = _product.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImgUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') ||
          !_imageUrlController.text.startsWith('https')) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState?.save();
    if (_product.id != '') {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_product.id, _product);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_product);
    }
    Navigator.of(context).pop();
  }

  Widget _buildTextFormField(
    Function(String?) onSaved,
    String labelText,
    String? Function(String?)? validator,
    String? initialValue, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      textInputAction: action,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _saveForm();
              },
              icon: const Icon(
                Icons.save,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildTextFormField(
                    (newValue) => _product = Product(
                          isFavorite: _product.isFavorite,
                          id: _product.id,
                          title: newValue!,
                          description: _product.description,
                          price: _product.price,
                          imageUrl: _product.imageUrl,
                        ),
                    'Title', (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                }, _initValue['title']),
                _buildTextFormField(
                  (newValue) => _product = Product(
                    isFavorite: _product.isFavorite,
                    id: _product.id,
                    title: _product.title,
                    description: _product.description,
                    price: double.parse(newValue!),
                    imageUrl: _product.imageUrl,
                  ),
                  'Price',
                  (value) {
                    if (value!.isEmpty) {
                      return 'Please provide a value.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please enter a number greater than 0';
                    }
                    return null;
                  },
                  _initValue['price'],
                  keyboardType: TextInputType.number,
                ),
                _buildTextFormField(
                  (newValue) => _product = Product(
                    isFavorite: _product.isFavorite,
                    id: _product.id,
                    title: _product.title,
                    description: newValue!,
                    price: _product.price,
                    imageUrl: _product.imageUrl,
                  ),
                  'Description',
                  (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description.';
                    }
                    if (value.length < 10) {
                      return 'Description should be at least 10 characters long.';
                    }
                    return null;
                  },
                  _initValue['description'],
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  action: TextInputAction.newline,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey)),
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? const Center(child: Text('Enter a URL'))
                          : FittedBox(
                              child: Image.network(
                                _imageUrlController.text,
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        onSaved: (newValue) => _product = Product(
                          isFavorite: _product.isFavorite,
                          id: _product.id,
                          title: _product.title,
                          description: newValue!,
                          price: _product.price,
                          imageUrl: newValue,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Image Url',
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        onFieldSubmitted: (_) => _saveForm(),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an image URL.';
                          }
                          if (!value.startsWith('http') ||
                              !value.startsWith('https')) {
                            return 'Please enter a valid url';
                          }
                          return null;
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
