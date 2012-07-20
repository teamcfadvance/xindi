/*
	Xindi - http://www.getxindi.com/
	
	Copyright (c) 2012, Simon Bingham
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
	modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
	is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
	IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

component persistent="true" table="users" cacheuse="transactional"{

	// ------------------------ PROPERTIES ------------------------ //	
	
	property name="userid" column="user_id" fieldtype="id" setter="false" generator="native";

	property name="firstname" column="user_firstname" ormtype="string" length="50";
	property name="lastname" column="user_lastname" ormtype="string" length="50";
	property name="email" column="user_email" ormtype="string" length="150";
	property name="username" column="user_username" ormtype="string" length="50";
	property name="password" column="user_password" ormtype="string" length="65" setter="false";
	property name="created" column="user_created" ormtype="timestamp";
	property name="updated" column="user_updated" ormtype="timestamp";
	
	// ------------------------ PUBLIC METHODS ------------------------ //

	/**
	 * I initialise this component
	 */		
	User function init(){
		return this;
	}
	
	/**
	 * I return the full name
	 */		
	string function getFullName(){
		return variables.firstname & " " & variables.lastname;
	}

	/**
	 * I return true if the email address is unique
	 */		
	struct function isEmailUnique(){
		var matches = []; 
		var result = { issuccess=false, failuremessage="The email address '#variables.email#' is registered to an existing account." };
		if( isPersisted() ) matches = ORMExecuteQuery( "from User where userid <> :userid and email = :email", { userid=variables.userid, email=variables.email } );
		else matches = ORMExecuteQuery( "from User where email=:email", { email=variables.email } );
		if( !ArrayLen( matches ) ) result.issuccess = true;
		return result;
	}

	/**
	 * I return true if the username is unique
	 */	
	struct function isUsernameUnique(){
		var matches = []; 
		var result = { issuccess = false, failuremessage = "The username '#variables.username#' is registered to an existing account." };
		if( isPersisted() ) matches = ORMExecuteQuery( "from User where userid <> :userid and username = :username", { userid=variables.userid, username=variables.username } );
		else matches = OrmExecuteQuery( "from User where username = :username", { username=variables.username } );
		if( !ArrayLen( matches ) ) result.issuccess = true;
		return result;
	}	

	/**
	 * I return true if the user is persisted
	 */	
	boolean function isPersisted(){
		return !IsNull( variables.userid );
	}
	
	/**
	* I override the implicit setter to include hashing of the password
	*/
	string function setPassword( required password ){
		if( arguments.password != "" ){
			variables.password = arguments.password;
			// to help prevent rainbow attacks hash several times
			for ( var i=0; i<50; i++ ){			
				variables.password = Hash( variables.password, "SHA-256" );
			}
		}
	}
	
}