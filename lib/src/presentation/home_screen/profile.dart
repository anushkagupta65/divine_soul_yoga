// Import necessary packages
import 'dart:convert';
import 'dart:developer';

import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/home_screen.dart';
import 'package:divine_soul_yoga/src/models/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final String? index;
  final String? userId;

  const Profile({
    required this.index,
    this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "";
  String mobile = "";
  DateFormat dob = DateFormat('yyyy-MM-DD');
  String email = "";
  String city = "";
  String state = "";
  String address = "";
  String userID = "";
  String? profile_image = "";
  bool isloading = false;
  late String? cityValue = '';
  //List<String> cities = ['New York', 'Los Angeles', 'Chicago', 'Houston'];
  //List<String> states = ['California', 'Texas', 'Florida', 'New York'];

  TextEditingController nameController = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController stateController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  List<Map<String, dynamic>> states = [];
  List<String> cities = [];
  bool isLoadingStates = true;
  bool isLoadingCities = false;

  String mobileRegister = '';

  void getMobile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileRegister = prefs.getString('registerMobile');

    if (mobileRegister != null) {
      mobileController = TextEditingController(text: mobileRegister);
    } else {
      mobileController = TextEditingController(); // Default empty controller
    }
  }

  Future<List<String>> getCityData(String stateId) async {
    final String url = 'https://divinesoulyoga.in/api/get-city-Data/$stateId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        return data.map<String>((city) => city['city_name']).toList();
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStateData() async {
    const String url = 'https://divinesoulyoga.in/api/state-Data';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        return data.map<Map<String, dynamic>>((state) {
          //cityValue = state['id'];
          return {
            'id': state['id'].toString(), // Convert ID to string for dropdown
            'name': state['state_name']
          };
        }).toList();
      } else {
        throw Exception('Failed to load states');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> postProfileData() async {
    setState(() {
      isloading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {
      'Cookie':
          'XSRF-TOKEN=eyJpdiI6IlgvR1YzRG81NzF1S2dLbTZEb0trOGc9PSIsInZhbHVlIjoiTjY0ZVJFVVBSWjBsUy9hRVNraHRXY2UxQmV6eEcrQlNyRk54NVdYNllkanhpUjJlb3dkeGs5OHIyL3VacVNtVFpPcHpleWdZdHlyMHErU0d4UWlYdEZBOXNmVmExREpwajZKRGlBanVnKzA3WWhLY3Q0ZDk3anRsTU0vNy95ZkoiLCJtYWMiOiI3OTYwY2I3MGVkN2Q2NTU0ZjBkNmJmYjk5ZmUwNjVjOGE0NWY2MzZmNmY5MDU3NmE4MjkxMjcxNGE4YzViM2NlIiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im9hVU10Qkd6YWhPL1RQYnVVZmRWTEE9PSIsInZhbHVlIjoiR0Vleit5bGNsM29tdmo0cEp2aHI4QU5yN3lmOHNUVU40ejhPTzVTZmJCTWwxdTkvVlNvcGt2dzF4NGpUWHZOYlpGNEVtdmhianVQL2dYMUE1MDcybzFDaENMUU9sM2Z2Z1FSTFRQSXg4WWZ4UFpZcE50L3pobDBpMWtYcmR2d08iLCJtYWMiOiI0MzdhODM4YmRlMzA0MmYzNWRjMGExMDgzMGEwZDk0MDI5Mjc1YzhiMzA3OWViYWFjNmNkYzc0N2ZhMzlmYTBkIiwidGFnIjoiIn0%3D'
    };

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://68.183.83.189/api/getProfile'));

    String? userId = prefs.getString('user_id');
    // Add fields to the request
    request.fields.addAll({
      'id': userId! // Replace this with the ID value you want to send
    });

    // Add headers to the request
    request.headers.addAll(headers);

    try {
      // Send the request
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print(responseBody);

        var data = jsonDecode(responseBody);

        name = data["user"]["name"];
        mobile = data["user"]["mobile"];
        String date =
            data["user"]["dob"].toString() == 'null' ? '' : data["user"]["dob"];
        email = data["user"]["email"];
        city = data["user"]["city"];
        state = data["user"]["state"];
        address = data["user"]["address"];
        profile_image = data["user"]["profile_image"];
        cityValue = data["user"]["city"];
        print('city data: ${city}');
        print('city data: ${cityValue}');

        dob = DateFormat('yyyy-MM-dd ');
        DateTime parsedDate = DateTime.parse(date);

        nameController = TextEditingController(text: name ?? "");
        dobController = TextEditingController(
            text: dob != null ? dob!.format(parsedDate) : '');
        // dobController = TextEditingController(
        //     text: widget.userProfile.dob?.toLocal().toString().split(' ')[0] ?? '');
        mobileController = TextEditingController(text: mobile ?? "");
        emailController = TextEditingController(text: email ?? '');
        cityController = TextEditingController(text: city ?? '');
        stateController = TextEditingController(text: state ?? '');
        addressController = TextEditingController(text: address ?? '');
        prefs.setString("user_id", data["user"]["id"]);

        print("Name in profile${data["user"]["name"]}");
        print(city);
        print(state);

        print('Profile data posted successfully');
        setState(() {
          isloading = false;
        });
      } else {
        print('Failed to post data: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      print('Error sending request: $e');
    }
  }

  File? _imageFile;
  // Define TextEditingControllers for each field

  // Define a GlobalKey for the form
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    postProfileData();
    getUserid();
    fetchStates();
    fetchInitialData();
    getMobile();

    // Initialize the controllers with the data from userProfile
  }

  Future<void> fetchStates() async {
    try {
      final stateList = await getStateData();
      setState(() {
        states = stateList;
        isLoadingStates = false;
        //fetchCities(cityValue!);
      });
    } catch (e) {
      setState(() {
        isLoadingStates = false;
      });
      print('Error fetching states: $e');
    }
  }

  Future<void> fetchCities(String stateId) async {
    setState(() {
      isLoadingCities = true;
      cities = []; // Clear previous cities
      cityController.text = ''; // Clear city selection
    });

    try {
      final cityNames = await getCityData(stateId);
      setState(() {
        cities = cityNames;
        isLoadingCities = false;

        // Set the city from the API if it exists in the fetched cities
        if (cityNames.contains(city)) {
          cityController.text = city;
        }
      });
    } catch (e) {
      setState(() {
        isLoadingCities = false;
      });
      print('Error fetching cities: $e');
    }
  }

  Future<void> fetchInitialData() async {
    setState(() {
      isLoadingStates = true;
      isLoadingCities = true;
    });

    try {
      // Fetch user profile data
      await postProfileData();

      // Fetch states
      final stateList = await getStateData();
      setState(() {
        states = stateList;
        isLoadingStates = false;
      });

      // Find the state ID based on user's state from profile
      final userState = states.firstWhere(
        (state) => state['name'] == stateController.text,
        orElse: () => {'id': ''},
      );

      if (userState['id'] != '') {
        // Fetch cities for the user's state
        await fetchCities(userState['id']);
      }
    } catch (e) {
      setState(() {
        isLoadingStates = false;
        isLoadingCities = false;
      });
      print('Error fetching initial data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed
    // nameController.dispose();
    dobController.dispose();
    mobileController.dispose();
    emailController.dispose();
    //cityController.dispose();
    stateController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Open the date picker and store the selected date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // The earliest date the user can select
      lastDate: DateTime.now(), // The latest date the user can select
    );

    if (pickedDate != null) {
      // Update the text field with the selected date
      // setState(() {
      //   dobController.text =
      //       "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      // });
      setState(() {
        dobController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    await _requestPermissions(); // Request necessary permissions

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to get image from selected source
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        debugPrint('Picked Image Path: ${pickedFile.path}');
        _imageFile = File(pickedFile.path);
        profile_image = pickedFile.path;
      });
    }
  }

  // Request permissions
  Future<void> _requestPermissions() async {
    var status = await Permission.storage.request();
    var cameraStatus = await Permission.camera.request();

    if (!status.isGranted || !cameraStatus.isGranted) {
      debugPrint('Permissions denied');
    }
  }

  // Future<void> _pickImage() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       print('Picked Image Path: ${pickedFile.path}');
  //       _imageFile = File(pickedFile.path); // Save the file for uploading
  //       profile_image = pickedFile.path; // Update the displayed image source
  //     });
  //   }
  // }

  String getFormattedDobForApi() {
    // Parse dobController.text to DateTime assuming it's in dd-MM-yyyy format
    DateTime dob = DateFormat('dd-MM-yyyy').parse(dobController.text);

    // Format the DateTime to yyyy-MM-dd
    return DateFormat('yyyy-MM-dd').format(dob);
  }

  Future<void> getUserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("user_id")!;
    print("User Id in profile${userID}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey, // Wrap with Form widget
                child: Column(
                  children: <Widget>[
                    // Header section with image and user's name
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide.none)),
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: DrawerHeader(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide.none),
                          image: DecorationImage(
                            image: AssetImage('assets/images/vector1.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.index == "1") {
                                        Navigator.pop(context);
                                      } else if (widget.index == "0") {
                                        SystemNavigator.pop(); // Closes the app
                                      }
                                    },
                                    child: Image.asset(
                                      "assets/images/ph_arrow.png",
                                      width: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage: _imageFile != null
                                        ? FileImage(
                                            _imageFile!) // Display the picked image
                                        : (profile_image != null &&
                                                profile_image!.isNotEmpty
                                            ? NetworkImage(
                                                profile_image!) // Display the API image
                                            : AssetImage(
                                                    "assets/images/act1.png")
                                                as ImageProvider), // Default image
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.camera_alt,
                                        color: Colors.blue,
                                      ),
                                      onPressed: _pickImage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Editable fields with controllers and validation
                    _buildTextField(
                      controller: nameController,
                      label: 'Name',
                      hintText: 'Enter your Name',
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                    _buildTextField(
                      controller: dobController,
                      label: 'Date of Birth',
                      hintText: 'Enter your Date of Birth',
                      validator: (value) =>
                          value!.isEmpty ? 'Date of Birth is required' : null,
                      onTap: () => _selectDate(context),
                    ),
                    // _buildTextField(
                    //   controller: mobileController,
                    //   label: 'Mobile Number',
                    //   hintText: 'Enter your Mobile Number',
                    //   validator: (value) =>
                    //       value!.isEmpty ? 'Mobile Number is required' : null,
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: mobileController,
                          style:
                              TextStyle(fontSize: 20, color: Color(0xffD45700)),
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: 'Enter your Mobile Number',
                            labelText: 'Mobile Number',
                            labelStyle: TextStyle(
                                fontSize: 18, color: Color(0xffD45700)),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff000000)),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      hintText: 'Enter your Email',
                      validator: (value) {
                        if (value!.isEmpty) return 'Email is required';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value))
                          return 'Enter a valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: 25),
                    // Define your dropdown options
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: isLoadingStates
                            ? Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                value: states
                                        .map((state) => state['name'])
                                        .contains(stateController.text)
                                    ? stateController.text
                                    : null,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    stateController.text = newValue!;
                                  });

                                  // Find the ID of the selected state
                                  final selectedState = states.firstWhere(
                                    (state) => state['name'] == newValue,
                                    orElse: () => {
                                      'id': '',
                                      'name': ''
                                    }, // Return an empty map
                                  );

                                  if (selectedState['id'] != '') {
                                    final selectedStateId = selectedState['id'];
                                    fetchCities(selectedStateId);
                                  }
                                },
                                items: states
                                    .map<DropdownMenuItem<String>>((state) {
                                  return DropdownMenuItem<String>(
                                    value: state['name'],
                                    child: Text(
                                      state['name'],
                                      style:
                                          TextStyle(color: Color(0xffD45700)),
                                    ),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                    labelText: 'State',
                                    labelStyle:
                                        TextStyle(color: Color(0xffD45700)),
                                    hintText: 'Select your State',
                                    hintStyle:
                                        TextStyle(color: Color(0xffD45700))),
                              )),
                    SizedBox(height: 25),
// City Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child:
                          // isLoadingCities
                          //     ? Center(child: CircularProgressIndicator())
                          //     :
                          DropdownButtonFormField<String>(
                        value: cities.contains(cityController.text)
                            ? cityController.text
                            : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            cityController.text = newValue ?? '';
                          });
                        },
                        items: cities.map<DropdownMenuItem<String>>((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city,
                                style: TextStyle(color: Color(0xffD45700))),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'City',
                          labelStyle: TextStyle(color: Color(0xffD45700)),
                          hintText: 'Select your City',
                        ),
                      ),
                    ),

                    //SizedBox(height: 25),

// State Dropdown

                    _buildTextField(
                      controller: addressController,
                      label: 'Address',
                      hintText: 'Enter your Address',
                      validator: (value) =>
                          value!.isEmpty ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.all(70.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (_formKey.currentState!.validate()) {
                            //prefs.setBool("name", true);
                            ApiService apiService = new ApiService();
                            await apiService.updateUser(
                                nameController.text,
                                emailController.text,
                                userID!,
                                mobileController.text.toString(),
                                cityController.text,
                                stateController.text,
                                addressController.text,
                                dobController.text,
                                _imageFile);

                            String dobForApi = getFormattedDobForApi();
                            // Proceed if the form is valid
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffD45700),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to build text fields with validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: TextFormField(
          controller: controller,
          style: TextStyle(fontSize: 20, color: Color(0xffD45700)),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintText: hintText,
            labelText: label,
            labelStyle: TextStyle(fontSize: 18, color: Color(0xffD45700)),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff000000)),
            ),
          ),
          validator: validator,
          // Makes the text field read-only so only date picker sets the date
          onTap: onTap,
        ),
      ),
    );
  }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   required String hintText,
  //   required String? Function(String?) validator,
  //   VoidCallback? onTap,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 25.0),
  //     child: Container(
  //       margin: EdgeInsets.only(left: 20, right: 20),
  //       child: TextFormField(
  //         controller: controller,
  //         style: TextStyle(fontSize: 20, color: Color(0xffD45700)),
  //         decoration: InputDecoration(
  //           focusedBorder: UnderlineInputBorder(
  //             borderSide: BorderSide(color: Colors.black),
  //           ),
  //           hintText: hintText,
  //           labelText: label,
  //           labelStyle: TextStyle(fontSize: 18, color: Color(0xFF000000)),
  //           border: UnderlineInputBorder(
  //             borderSide: BorderSide(color: Color(0xff000000)),
  //           ),
  //         ),
  //         validator: validator,
  //         readOnly:
  //             true, // Prevents manual input, so only date picker sets the date
  //         onTap: onTap,
  //       ),
  //     ),
  //   );
  // }

  void updateProfile() async {
    // Truncate state value to prevent SQL error
    String truncatedState = state.length > 30 ? state.substring(0, 30) : state;

    try {
      // Your API call with truncated state
      final response = await http.post(
        Uri.parse('your_api_endpoint'),
        body: {
          // ... other fields
          'state': truncatedState,
          // ... other fields
        },
      );

      if (response.statusCode == 200) {
        // Handle success
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
        await prefs.setString('state', truncatedState);
        // ... save other fields

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      }
    } catch (e) {
      log("Error updating profile: $e");
      // Handle error
    }
  }
}
