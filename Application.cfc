/*
   Copyright 2012, Simon Bingham

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

component extends="frameworks.org.corfield.framework"
{
	
	/**
	* application settings
	*/
	this.development = CGI.SERVER_NAME == "localhost";
	this.applicationroot = getDirectoryFromPath( getCurrentTemplatePath() );
	this.sessionmanagement = true;
	this.mappings[ "/model" ] = this.applicationroot & "model/";
	this.mappings[ "/ValidateThis" ] = this.applicationroot & "frameworks/ValidateThis/";
	this.datasource = ListLast( this.applicationroot, "\/" );
	this.ormenabled = true;
	this.ormsettings = {
		flushatrequestend = false,
		automanagesession = false,
		cfclocation = this.mappings[ "/model" ],
		dbcreate = "update",
		sqlscript = this.applicationroot & "_setup/setup.sql",
		eventhandling = true
	};

	/**
	* FW/1 framework settings (https://github.com/seancorfield/fw1)
	*/
	variables.framework = {
		cacheFileExists = !this.development,
		defaultSubsystem = "public",
		generateSES = true,
		maxNumContextsPreserved = 1,
		password = "",
		reloadApplicationOnEveryRequest = this.development,
		usingSubsystems = true
	};
	
	/**
     * called when application starts
	 */	
	void function setupApplication()
	{
		ORMReload();
		
		// setup bean factory
		var beanfactory = new frameworks.org.corfield.ioc( "/model" );
		setBeanFactory( beanfactory );
		
		// setup validation framework
		var ValidateThisConfig = { definitionPath="/model/" };
		application.ValidateThis = CreateObject( "component", "ValidateThis.ValidateThis" ).init( ValidateThisConfig );
		
		// define revision identifier
		application.revision = Hash( Now() );
		
		// define error settings
		application.errorsettings = { enabled=true, to="smnbin@gmail.com", from="smnbin@gmail.com", subject="Error Notification (#ListLast( this.applicationroot, '\/' )#)" };
		
		// define page settings
		application.pagesettings = { enableadddelete=true };
	}
	
	/**
     * called when page request starts
	 */	
	void function setupRequest()
	{
		// define base url
	  	rc.basehref = "//" & CGI.SERVER_NAME & variables.framework.base;
	  	
	  	// define default meta data
		rc.MetaData = getBeanFactory().getBean( "MetaData" );
		rc.MetaData.setMetaTitle( "" ); 
		rc.MetaData.setMetaDescription( "" );
		rc.MetaData.setMetaKeywords( "" );
		
		// store revision identifier in request context
		rc.revision = application.revision; 
	}
	
	/**
     * called when view rendering begins
	 */		
	void function setupView()
	{
		rc.navigation = getBeanFactory().getBean( "PageService" ).getPages();
	}	
	
	/**
     * called if view is missing
	 */	
	any function onMissingView( required rc )
	{
		rc.Page = getBeanFactory().getBean( "PageService" ).getPageBySlug( rc.action );
		if ( rc.Page.isPersisted )
		{
			rc.MetaData.setMetaTitle( rc.Page.getMetaTitle() ); 
			rc.MetaData.setMetaDescription( rc.Page.getMetaDescription() );
			rc.MetaData.setMetaKeywords( rc.Page.getMetaKeywords() );			
			return view( "public:main/default" );
		}
		else
		{
			var pagecontext = getPageContext().getResponse();
			pagecontext.getResponse().setStatus( 404 );
			return view( "public:main/notfound" );
		}
	}

}