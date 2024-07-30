# QVTR-XSLT: Model Transformation with QVT-R and XSLT

## Tool Description

QVTR-XSLT  is a model transformation tool that provides support for QVT Relations in graphical notation andautomatic transformation execution. It consists of a QVT Relations graphical editor and a code generator.  The graphical editor supports design of QVT transformations by defining  metamodels, specifying QVT rules as UML object diagrams with OCL expressions. The code generator translates the transformations  into executable XSLT programs.

Currently, the tool supports complex pattern matching of QVT object template, collection template (member selection only), not template, and execution trace output. The source and target models can share the same metamodel, or have different metamodels. The OCL navigation expressions can start from an object template of source domain pattern, navigate along the links to collect objects or attributes. It also supports a set of OCL operations, such as forAll, select, including, size(), etc. The tool supports transformation parameters, transformation inheritance through rules overriding, and multiple input and output models. 
Furthermore, in-place  transformations are defined as modification (insert, remove, replace) of the existing model elements.

## What inside the tool package

The tool archive *QVTR-XSLT_tool.zip*  includes the follwoing files and directories:

- *QVTRtoXSLT.jar* :  The XSLT code generator.

- *QVTR_Profile.mdzip*:  The QVTR UML profile.

- *QVTRelation Diagram descriptor.xml* : The toolbar definition file for the QVTR editor

- *XSLTrunner.jar* : The transformation runner.

- *my_XMI_Merge.xslt*: Additional common functions for transformation execution. This file may need to be put in the same directory with the generated XSLT files.

- *UMLtoDB_example* : The directory contains files for the famous UML to RDBMS transformation case study.

## More examples

- UML to RDBMS transformation.

- Multiplicity to OCL transformation.

- UML Activity Diagrams to CSP transformation.

- CSP to Html transformation.

- Class to Component transformation.

- UML Sequence Diagrams To CSP transformation.

- Examples of Model Querying with QVT-R graphical notation.
