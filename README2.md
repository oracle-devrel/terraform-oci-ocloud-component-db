# Managing Data
The Oracle [Database Cloud Service][database_doc] provides a unique combination of the simplicity and ease of use promised by Cloud computing and the power, productivity and robustness which are the hallmarks of Oracle technology. The [Database Cloud Service][database_video] has three main components – RESTful Web service access, which allows access to the data in your Database Cloud Service through simple URIs, Oracle Application Express, for creating and deploying all varieties of applications in a browser­based environment, and a set of business productivity applications that can be installed with just a few clicks.

## Oracle Cloud Infrastructure Storage Strategies
When you think of storage, it doesn't always have to be a database or simple file storage.
Rather, the first step is to be clear about the purpose of the storage and then make a choice in the second step.
And that is one of the great advantages of Oracle Cloud Infrastructure. On the one hand, you have the choice between several storage variants, whether file storage or database. On the other hand, once you have made your choice, you are not bound to it forever. If the requirements or the conditions change, you can revise your decision for a technology at any time and make a different choice.
Not all data necessarily needs to be stored in a database. Here are just a few types of data that you would store outside of a database:
-	Log Files, streaming data 
-	Unstructured data
-	Documents
-	Historical data / archives
In a balanced cloud storage architecture, one should control the amount of data in a database and use databases for purposes for which they are well suited. E.G.:
-	e. g. Use relational databases only if you want have access with SQL
-	e. g. use relational databases to track relationships between data  

But in any case you should use the Oracle Database Cloud Service, if multistructured model variants are used in an integrated way, these can be
-	Relational data
-	JSON data
-	Graph models

We call this  “Converged Database Model”.

<img alt="Image1" src="docs/images/B1.png"> 

In cases where data is not to be stored in a database, several variants are available:

<img alt="Image2" src="docs/images/B2.png">
 
### Local NVMe
This storage is used extremely high performance requirements. NVMe storage is directly assigned to either a so-called bare metal or a virtual compute instance. If you want to store or archive data permanently, you will transfer such data to block or object storage for backup purposes, for example, after processing by an application has been completed.
### Block Volume
Block volume is NVMe SSD-based classic storage that can be temporarily attached to an instance and detached again without data loss. It is used, for example, as boot volumes or to exchange data from one compute instance to another. 
Block volumes support the handling of large amount of data in a special way: Block Volumes can be easily duplicated for backup purposes and transferred to other cloud regions. Volume Groups simplify the management of larger data volumes or block volumes of multiple instances. They can be managed simultaneously and in a standardized manner.
### File Storage
File Storage is used to give several compute instances the option to use data in a simultaneous manner. Applications access the data simultaneously. The file storage system manages all accesses of the various applications autonomously.
Think of master data to be read by multiple applications at the same time.
### Object Storage
Object storage is the universal mass storage par excellence. It is used to store differently structured data, i.e. texts, images, films, sound recordings, but also for log and streaming data.
Object storage can grow almost indefinitely, it is fail-safe (data is stored several times within the system), it is organized in clusters so that it can be read extremely fast by parallel processes. 
Object storage is particularly well suited for data lake applications.
At the same time, object storage is very cost-effective.
### Archive Storage
Archive storage behaves similarly to object storage, but is even more cost-effective. Archive storage is used for data that is rarely read.
 
<img alt="Image3" src="docs/images/B3.png">

### Data does not have to be held "either-or"
One of the great advantages of Oracle Cloud Infrastructure is the simultaneous use of data e.g. in Object Storage and in the Database. For example, 
•	parquet files in the object storage can be read from the database with SQL. 
•	You can create joins between object storage files and database tables. 
•	You can use partitioned tables, where the partitions are located both in the Database and in the Object Storage.
 
<img alt="Image4" src="docs/images/B4.png">


## Sample DB Stacks

The following DB Infrastructure Stacks do not represent a complete list of Database architectures which are supported by Oracle Cloud Infrastructure however it can act as a starting point for further development and deployments. 

- [Autonomous Database - Shared (WIP)](adb_s/README.md)
- [Database as a Service on VM (WIP)](dbaas/README.md)



[<][base] | [+][home] | [>][app-infra] 

<!--- Links -->
[home]:       /README.md
[intro]:      /step1-intro/README.md
[provider]:   /step1-provider/README.md
[base]:       /step2-base/README.md
[db-infra]:   /step3-dbinfra/README.md
[app-infra]:  /step4-appinfra/README.md
[workload]:   /step5-workload/README.md
[governance]: /step6-governance/README.md
[vizualize]:  /step7-vizualize/README.md


[code_hello]:       code/tenancy/hello.tf
[code_tenancy]:     code/tenancy/main.tf
[code_provider]:    code/tenancy/provider.tf
[code_tenancy]:     code/tenancy/tenancy.tf
[code_user]:        code/iam/user.tf
[code_compartment]: code/iam/compartment.tf

[oci_certification]: https://www.oracle.com/cloud/iaas/training/architect-associate.html
[oci_cli]:           https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/
[oci_cloud]:         https://www.oracle.com/cloud/
[oci_cloudshell]:    https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm
[oci_data]:          https://registry.terraform.io/providers/hashicorp/oci/latest/docs
[oci_sdk]:           https://docs.cloud.oracle.com/en-us/iaas/Content/API/SDKDocs/terraform.htm
[oci_freetier]:      http://signup.oraclecloud.com/
[oci_global]:        https://www.oracle.com/cloud/architecture-and-regions.html
[oci_learn]:         https://learn.oracle.com/ols/user-portal
[oci_learning]:      https://learn.oracle.com/ols/learning-path/become-oci-architect-associate/35644/75658
[oci_homeregion]:    https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingregions.htm
[oci_identifier]:    https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
[oci_identity]:      https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domains
[oci_ilom]:          https://www.oracle.com/servers/technologies/integrated-lights-out-manager.html
[oci_offbox]:        https://blogs.oracle.com/cloud-infrastructure/first-principles-l2-network-virtualization-for-lift-and-shift
[oci_provider]:      https://github.com/terraform-providers/terraform-provider-oci
[oci_region]:        https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_regions
[oci_regions]:       https://www.oracle.com/cloud/data-regions.html
[oci_regionmap]:     https://www.oracle.com/cloud/architecture-and-regions.html
[oci_sdk]:           https://docs.cloud.oracle.com/en-us/iaas/Content/API/SDKDocs/terraform.htm
[oci_tenancy]:       https://docs.oracle.com/en-us/iaas/Content/GSG/Concepts/settinguptenancy.htm
[oci_training]:      https://www.oracle.com/cloud/iaas/training/


[tf_doc]: https://registry.terraform.io/providers/hashicorp/oci/latest/docs
[cli_doc]: https://docs.cloud.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/
[iam_doc]: https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm
[network_doc]: https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm
[compute_doc]: https://docs.cloud.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm#Overview_of_the_Compute_Service
[storage_doc]: https://docs.cloud.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm
[database_doc]: https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/databaseoverview.htm

[iam_video]: https://www.youtube.com/playlist?list=PLKCk3OyNwIzuuA-wq2rVuxUE13rPTvzQZ
[network_video]: https://www.youtube.com/playlist?list=PLKCk3OyNwIzvHm2E-cGrmoMes-VwanT3P
[compute_video]: https://www.youtube.com/playlist?list=PLKCk3OyNwIzsAjIaUaVsKdXcfBOy6LASv
[storage_video]: https://www.youtube.com/playlist?list=PLKCk3OyNwIzu7zNtt_w1dXFOUbAjheMeo
[database_video]: https://www.youtube.com/watch?v=F4-sxIsnbKI&list=PLKCk3OyNwIzsfuB9kj1CTPavjgByJBXGK

[jmespath_site]: https://jmespath.org/tutorial.html
[jq_site]: https://stedolan.github.io/jq/
[jq_play]: https://jqplay.org/
[json_validate]: https://jsonlint.com/

[vsc_site]: https://code.visualstudio.com/

[terraform]: https://www.terraform.io/
[tf_examples]: https://github.com/terraform-providers/terraform-provider-oci/tree/master/examples
[tf_lint]: https://www.hashicorp.com/blog/announcing-the-terraform-visual-studio-code-extension-v2-0-0

[oci_regions]: https://www.oracle.com/cloud/data-regions.html
