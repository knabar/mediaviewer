#This page contains basic instructions for setting up your Flex development environment using Adobe Flex Builder 3.

# Introduction #

These instructions assume a fair degree of expertise with Adobe Flex Builder 3.


# Details #

This Flex project requires Flex SDK 3.4. Download the source code to a directory on your workstation and open this directory as a Workspace with Flex 3.

The workspace contains four Flex Projects:
  * **AirMediaViewer**. This is an AIR project and should compile with no modifications. However, it's configured to connect to http://mdid.org/demo. You can use this MDID2 installation for development purposes or go into [path](source.md)src > prefs > prefs.xml and point the app to your MDID2 installation.
  * **Common**. This is a Web Application Flex project. You will NOT compile this project. It holds the shared source code and libraries for the other three projects.
  * **WebMediaViewer**. This is a Web Application Flex project and contains the code that compiles a browser version of the MediaViewer. You will have to modify the Launch configurations (WebMediaViewer > Properties > Run/Debug Settings) to match your development environment. The source code contains to sample Launch Configurations that are used at JMU to compile both an MDID2 and MDID3 compatible SWF. Review and modify these configurations to match your development environment.
  * **ZincMediaViewer**. This is a Web Application Flex project. It is under construction. The code compiles but the SWF does nothing. Much work remains to be done to tie SWF into a Zinc project. Ultimately, the ZincMediaViewer will server as a standalone, offline package viewer that can be run directly from a USB drive.