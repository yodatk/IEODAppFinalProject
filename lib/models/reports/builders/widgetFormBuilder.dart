import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../constants/constants.dart' as Constants;
import '../../../widgets/permission_widgets/permission_widget.dart';
import '../bricks/ChoiceChipBrick.dart';
import '../bricks/ColumnBrick.dart';
import '../bricks/DateTimeBrick.dart';
import '../bricks/DropDownBrick.dart';
import '../bricks/EmptyBrick.dart';
import '../bricks/FunctionDropDownBrick.dart';
import '../bricks/PageBrick.dart';
import '../bricks/ReadOnlyTextBrick.dart';
import '../bricks/RowBrick.dart';
import '../bricks/TableBrick.dart';
import '../bricks/TextBrick.dart';
import '../bricks/TitleBrick.dart';
import '../bricks/parentBrick.dart';
import '../bricks/templateBrick.dart';
import '../templates/Template.dart';
import 'TemplateFormBuilder.dart';
import 'acceptFormBuilders.dart';

///
/// Part of the "BRICK WALL" pattern - convert each TemplatBrick to a [Widget]
///
class WidgetFormBuilder implements TemplateFormBuilder {
  final GlobalKey<FormBuilderState> _formKey;
  final Map<String, dynamic> _attributeMap;

  WidgetFormBuilder(this._formKey, this._attributeMap);

  FormBuilder buildForm(BuildContext context, Template template) {
    return FormBuilder(
        key: _formKey,
        child: Column(
          children: <Widget>[
            for (TemplateBrick brick in template.templateBricks)
              visit(context, brick)
          ],
        ));
  }

  Widget visit(BuildContext context, AcceptFormBuilders element) {
    return element.acceptForm(builder: this, context: context);
  }

  Widget buildTextBrick(BuildContext context, TextBrick brick, String suffix) {
    List<String Function(String value)> validators =
        <String Function(String value)>[];
    if (brick.maxLen != null && brick.maxLen > 0) {
      validators.add(FormBuilderValidators.maxLength(context, brick.maxLen,
          errorText: "הקלט ארוך מדי"));
    }
    TextInputType type = TextInputType.text;
    if (brick.isRequired)
      validators.add(FormBuilderValidators.required(
        context,
        errorText: 'שדה זה הינו חובה',
      ));
    if (brick.minLen > 0)
      validators.add(FormBuilderValidators.minLength(context, brick.minLen,
          errorText: "הקלט קצר מדי"));
    if (brick.isNumber) {
      type = TextInputType.number;
      validators.add(FormBuilderValidators.numeric(context,
          errorText: "הקלט חייב להיות מספר"));
    }
    return Container(
      width: (brick.lineLimit ?? Constants.TEXT_DEFAULT_ROW_LIMIT) * 10.0,
      child: PermissionWidget(
          permissionLevel: brick.permissionCanEdit,
          withPermission: FormBuilderTextField(
            key: Key(brick.attribute),
            initialValue: _attributeMap[brick.attribute + suffix] as String,
            enabled: true,
            maxLines: brick.lines,
            keyboardType: type,
            name: brick.attribute + suffix,
            decoration: InputDecoration(labelText: brick.decoration),
            validator: FormBuilderValidators.compose(validators),
            onSaved: (String value) {
              if (value != null && value.isNotEmpty)
                _attributeMap[brick.attribute + suffix] = value;
            },
          ),
          withoutPermission: FormBuilderTextField(
            key: Key(brick.attribute),
            initialValue: _attributeMap[brick.attribute + suffix] as String,
            enabled: false,
            maxLines: brick.lines,
            name: brick.attribute + suffix,
            decoration: InputDecoration(labelText: brick.decoration),
            validator: FormBuilderValidators.compose(validators),
            onSaved: (String value) {
              if (value != null && value.isNotEmpty)
                _attributeMap[brick.attribute + suffix] = value;
            },
          )),
    );
  }

  @override
  Widget buildReadOnlyTextBrick(
      BuildContext context, ReadOnlyTextBrick brick, String suffix) {
    return Container(
        width: brick.maxLen * 10.0,
        child: FormBuilderTextField(
          key: Key(brick.attribute),
          initialValue: brick.text,
          readOnly: true,
          enabled: false,
          // maxLines: brick.lines,
          name: brick.attribute + suffix,
          decoration: InputDecoration(labelText: brick.decoration),
          onSaved: (String value) {
            if (value != null && value.isNotEmpty)
              _attributeMap[brick.attribute + suffix] = value;
          },
        ));
  }

  Widget buildDropDownBrick(
      BuildContext context, DropDownBrick brick, String suffix) {
    List<String Function(String value)> validators = [];
    if (brick.isRequired)
      validators.add(FormBuilderValidators.required(
        context,
        errorText: 'שדה זה הינו חובה',
      ));
    List<DropdownMenuItem<String>> choices = brick.choices
        .map((choice) => DropdownMenuItem<String>(
            key: Key(choice),
            child: Text(
              choice,
              style: TextStyle(color: Colors.black),
            ),
            value: choice))
        .toList();
    return Container(
      child: PermissionWidget(
          permissionLevel: brick.permissionCanEdit,
          withPermission: DropdownButtonFormField<String>(
              key: Key(brick.attribute),
              value: _attributeMap[brick.attribute + suffix] as String,
              decoration: InputDecoration(labelText: brick.decoration),
              validator: FormBuilderValidators.compose(validators),
              onChanged: (String value) {
                if (value != null && value.isNotEmpty)
                  _attributeMap[brick.attribute + suffix] = value;
              },
              onSaved: (String value) {
                if (value != null && value.isNotEmpty)
                  _attributeMap[brick.attribute + suffix] = value;
              },
              items: choices),
          withoutPermission: FormBuilderTextField(
            key: Key(brick.attribute),
            initialValue: _attributeMap[brick.attribute + suffix] as String,
            readOnly: true,
            enabled: false,
            // maxLines: brick.lines,
            name: brick.attribute + suffix,
            decoration: InputDecoration(labelText: brick.decoration),
            onSaved: (String value) {
              if (value != null && value.isNotEmpty)
                _attributeMap[brick.attribute + suffix] = value;
            },
          )),
    );
  }

  void addExistingValueToChoices(FunctionDropDownBrick brick, String suffix) {
    if (brick.choices != null &&
        _attributeMap[brick.attribute + suffix] != null &&
        _attributeMap[brick.attribute + suffix] != "" &&
        !brick.choices.contains(_attributeMap[brick.attribute + suffix])) {
      // include the previously chosen option in the choices list
      brick.choices.add(_attributeMap[brick.attribute + suffix] as String);
    }
  }

  Widget buildFunctionDropDownBrick(
      BuildContext context, FunctionDropDownBrick brick, String suffix) {
    List<String Function(String value)> validators = [];
    if (brick.isRequired)
      validators.add(FormBuilderValidators.required(
        context,
        errorText: 'שדה זה הינו חובה',
      ));
    addExistingValueToChoices(brick, suffix);
    return Container(
      child: PermissionWidget(
        permissionLevel: brick.permissionCanEdit,
        withPermission: FormBuilderSearchableDropdown<String>(
          key: Key(brick.attribute),
          name: brick.attribute + suffix,
          onSaved: (String value) {
            if (value != null && value.isNotEmpty)
              _attributeMap[brick.attribute + suffix] = value;
          },
          onChanged: (String value) {
            if (value != null && value.isNotEmpty)
              _attributeMap[brick.attribute + suffix] = value;
          },
          decoration: InputDecoration(labelText: brick.decoration),
          initialValue: _attributeMap[brick.attribute + suffix] as String,
          items: brick.choices == null ? <String>[] : ["", ...brick.choices],
          mode: Mode.DIALOG,
        ),
        withoutPermission: FormBuilderTextField(
          key: Key(brick.attribute),
          initialValue: _attributeMap[brick.attribute + suffix] as String,
          readOnly: true,
          enabled: false,
          // maxLines: brick.lines,
          name: brick.attribute + suffix,
          decoration: InputDecoration(labelText: brick.decoration),
          onSaved: (String value) {
            if (value != null && value.isNotEmpty)
              _attributeMap[brick.attribute + suffix] = value;
          },
        ),
      ),
    );
  }

  Widget buildChoiceChipBrick(
      BuildContext context, ChoiceChipBrick brick, String suffix) {
    List<String Function(String value)> validators = [];
    if (brick.isRequired)
      validators.add(
        FormBuilderValidators.required(
          context,
          errorText: 'שדה זה הינו חובה',
        ),
      );
    return Container(
      child: PermissionWidget(
        permissionLevel: brick.permissionCanEdit,
        withPermission: FormBuilderChoiceChip<String>(
          key: Key(brick.attribute),
          initialValue: _attributeMap[brick.attribute + suffix] as String,
          enabled: true,
          name: brick.attribute + suffix,
          decoration: InputDecoration(labelText: brick.decoration),
          validator: FormBuilderValidators.compose(validators),
          onSaved: (String value) {
            if (value != null && value.isNotEmpty)
              _attributeMap[brick.attribute + suffix] = value;
          },
          spacing: 10,
          // alignment: WrapAlignment.center,
          selectedColor: Theme.of(context).accentColor,
          backgroundColor: Theme.of(context).primaryColor,
          options: brick.choices
              .map((choice) => FormBuilderFieldOption(
                  child: Text(
                    choice,
                    style: TextStyle(color: Colors.white),
                  ),
                  value: choice))
              .toList(),
        ),
        withoutPermission: FormBuilderChoiceChip<String>(
          key: Key(brick.attribute),
          initialValue: _attributeMap[brick.attribute + suffix] as String,
          enabled: false,
          name: brick.attribute + suffix,
          decoration: InputDecoration(labelText: brick.decoration),
          validator: FormBuilderValidators.compose(validators),
          onSaved: (String value) {
            if (value != null && value.isNotEmpty)
              _attributeMap[brick.attribute + suffix] = value;
          },
          spacing: 10,
          // alignment: WrapAlignment.center,
          selectedColor: Theme.of(context).accentColor,
          backgroundColor: Theme.of(context).primaryColor,
          options: brick.choices
              .map((choice) => FormBuilderFieldOption(
                  child: Text(
                    choice,
                    style: TextStyle(color: Colors.white),
                  ),
                  value: choice))
              .toList(),
        ),
      ),
    );
  }

  Widget buildDateBrick(
      BuildContext context, DateTimeBrick brick, String suffix) {
    List<String Function(DateTime)> validators = [];
    if (brick.isRequired)
      validators
          .add(FormBuilderValidators.required(context, errorText: "שדה חובה"));
    if (brick.maxDateTime != null)
      validators.add((DateTime valueCandidate) {
        if (valueCandidate != null &&
            (valueCandidate.isAfter(brick.maxDateTime))) {
          return "יש לסמן זמן מוקדם יותר";
        }
        return null;
      });
    if (brick.minDateTime != null)
      validators.add((DateTime valueCandidate) {
        if (valueCandidate != null &&
            (valueCandidate.isBefore(brick.minDateTime))) {
          return "יש לסמן זמן מאוחר יותר";
        }
        return null;
      });
    return Container(
      child: PermissionWidget(
        permissionLevel: brick.permissionCanEdit,
        withPermission: FormBuilderDateTimePicker(
          key: Key(brick.attribute),
          locale: Localizations.localeOf(context),
          initialValue: _attributeMap[brick.attribute + suffix] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  _attributeMap[brick.attribute + suffix] as int)
              : null,
          enabled: true,
          name: brick.attribute + suffix,
          cursorWidth: brick.width * 10,
          inputType: brick.input,
          decoration: InputDecoration(labelText: brick.decoration),
          validator: FormBuilderValidators.compose(validators),
          onSaved: (DateTime value) {
            if (value != null)
              _attributeMap[brick.attribute + suffix] =
                  value.millisecondsSinceEpoch;
          },
        ),
        withoutPermission: FormBuilderDateTimePicker(
          key: Key(brick.attribute),
          initialValue: _attributeMap[brick.attribute + suffix] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  _attributeMap[brick.attribute + suffix] as int)
              : null,
          enabled: false,
          name: brick.attribute + suffix,
          cursorWidth: brick.width * 10,
          inputType: brick.input,
          decoration: InputDecoration(labelText: brick.decoration),
          validator: FormBuilderValidators.compose(validators),
          onSaved: (DateTime value) {
            if (value != null)
              _attributeMap[brick.attribute + suffix] =
                  value.millisecondsSinceEpoch;
          },
        ),
      ),
    );
  }

  @override
  Widget buildRowBrick(BuildContext context, RowBrick brick) {
    double width = 100;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (TemplateBrick brick in brick.children)
          SizedBox(
            width: width,
            child: brick.acceptForm(
              builder: this,
              context: context,
            ),
          )
      ],
    );
  }

  @override
  Widget buildColumnBrick(BuildContext context, ColumnBrick brick) {
    return Column(
      children: buildChildrenBricks(brick, context),
    );
  }

  List<Widget> buildChildrenBricks(ParentBrick brick, BuildContext context) {
    return [
      for (TemplateBrick brick in brick.children)
        brick.acceptForm(builder: this, context: context)
    ];
  }

  @override
  Widget buildTableBrick(BuildContext context, TableBrick brick) {
    return DynamicTable(brick, _formKey, _attributeMap, this);
  }

  @override
  Widget buildTitleBrick(BuildContext context, TitleBrick brick) {
    Map<TitleSizeEnum, TextStyle> themeMap = {
      TitleSizeEnum.HEADLINE_1: Theme.of(context).textTheme.headline1,
      TitleSizeEnum.HEADLINE_2: Theme.of(context).textTheme.headline2,
      TitleSizeEnum.HEADLINE_3: Theme.of(context).textTheme.headline3,
      TitleSizeEnum.HEADLINE_4: Theme.of(context).textTheme.headline4,
      TitleSizeEnum.HEADLINE_5: Theme.of(context).textTheme.headline5,
      TitleSizeEnum.HEADLINE_6: Theme.of(context).textTheme.headline6
    };
    return Text(
      brick.text,
      style: themeMap[brick.titleSize],
      textAlign: TextAlign.right,
    );
  }

  @override
  Widget buildPageBrick(BuildContext context, PageBrick brick) {
    return SizedBox.shrink();
  }

  @override
  Widget buildEmptyBrick(BuildContext context, EmptyBrick brick) {
    return SizedBox(
      height: brick.height,
    );
  }
}

class DynamicTable extends StatefulWidget {
  final TableBrick brick;
  final GlobalKey<FormBuilderState> formKey;
  final Map<String, dynamic> attributeMap;
  final WidgetFormBuilder builder;

  const DynamicTable(this.brick, this.formKey, this.attributeMap, this.builder);

  @override
  _DynamicTableState createState() =>
      _DynamicTableState(this.brick, this.attributeMap, this.builder);
}

class _DynamicTableState extends State<DynamicTable> {
  TableBrick brick;
  Map<String, dynamic> attributeMap;
  WidgetFormBuilder builder;

  _DynamicTableState(this.brick, this.attributeMap, this.builder);

  @override
  void initState() {
    final temp = this.brick.rowCount;
    this.brick.rowCount =
        this.attributeMap[brick.attribute + "_rowCount"] as int ?? temp;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: "הוספת שורה לטבלה",
                onPressed: () {
                  setState(() {
                    brick.rowCount += 1;
                    this.attributeMap[brick.attribute + "_rowCount"] =
                        this.brick.rowCount;
                  });
                },
              ),
              SizedBox(
                width: 3,
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                tooltip: "הורדת שורה מהטבלה",
                onPressed: () {
                  setState(() {
                    for (TemplateBrick child in brick.children) {
                      this
                          .attributeMap
                          .remove(child.attribute + "_${brick.rowCount}");
                    }
                    brick.rowCount =
                        brick.rowCount <= 1 ? 1 : brick.rowCount - 1;
                    this.attributeMap[brick.attribute + "_rowCount"] =
                        this.brick.rowCount;
                  });
                },
              ),
            ],
          ),
          DataTable(
              columnSpacing: 10,
              columns: <DataColumn>[
                DataColumn(label: Text("מס״ד")),
                for (TemplateBrick child in brick.children)
                  DataColumn(label: Text(child.attribute))
              ],
              headingRowHeight: brick.showColumnNames ? 56.0 : 0,
              dataRowHeight: 100,
              rows: <DataRow>[
                for (int row = 1; row <= brick.rowCount; row++)
                  DataRow(cells: <DataCell>[
                    DataCell(Text(row.toString())),
                    for (TemplateBrick child in brick.children)
                      DataCell(child.acceptForm(
                          context: context, builder: builder, suffix: '_$row'))
                  ])
              ]),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
