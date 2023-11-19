sayHello() {
  //console.log("HI THERE!!!");
}
getRecord(arr, prop, val) {
  if (arr != null) {
    if (arr.length > 0) {
      if (arr[0][prop] != null) {
        for (var i = 0; i < arr.length; i++) {
          //if (arr[i][prop]).toString().trim().toUpperCase().replace(/-/g, '') == String(val).trim().toUpperCase().replace(/-/g, '')) return arr[i];
        }
        //console.log("getRecord NOT FOUND");
        return "FALSE"; //IF NOT FOUND
      } else {
        //console.log("getRecord PROP NOT EXIST");
        return "FALSE"; //IF PROPERTY DOES NOT EXIST
      }
    } else {
      //console.log("getRecord ARR LENGTH=0");
      return "FALSE"; //IF ARR LENGTH IS 0
    }
  } else {
    //console.log("getRecord ARR IS NULL");
    return "FALSE"; //IF ARR IS NULL
  }
}

getIndex(arr, prop, val) {
  //console.log("getIndex called.");
  if (arr != null) {
    if (prop != null) {
      if (arr.length > 0) {
        if (arr[0][prop] != null) {
          //console.log("getIndex arr[0][prop] = " + arr[0][prop]);
          for (int i = 0; i < arr.length; i++) {
            if (arr[i][prop].toString() == val) return i;
          }
          //console.log("getIndex . NOT FOUND");
          return "FALSE"; //NOT FOUND
        } else {
          //console.log("getIndex . IF PROPERTY DOES NOT EXIST");
          return "FALSE"; //IF PROPERTY DOES NOT EXIST
        }
      } else {
        //console.log("getIndex . ARR LENGTH IS 0");
        return "FALSE"; //ARR LENGTH IS 0
      }
    } else {
      //console.log("getIndex . PROP IS NULL");
      return "FALSE"; //PROP IS NULL
    }
  } else {
    //console.log("getIndex . ARR IS NULL");
    return "FALSE"; //ARR IS NULL
  }
}
