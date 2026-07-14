import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/report_controller.dart';
import '../theme/app_theme.dart';


class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}


class _ReviewScreenState extends State<ReviewScreen> {

  final ReportController reportController = Get.put(ReportController());


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reportController.getReports();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Reports",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),


      body: RefreshIndicator(
        onRefresh: ()async{
          reportController.getReports();
        },
        child: Obx(() {

          if(reportController.isLoading.value){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if(reportController.reportsList.isEmpty){
            return const Center(
              child: Text(
                "No reports available",
                style: TextStyle(
                  color: AppColors.dim,
                ),
              ),
            );
          }



          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportController.reportsList.length,
            itemBuilder: (context,index){

              final report = reportController.reportsList[index];

              return ReportCard(
                report: report,
              );
            },
          );

        }),
      ),
    );
  }
}



class ReportCard extends StatelessWidget {

  final dynamic report;

  const ReportCard({
    super.key,
    required this.report,
  });


  @override
  Widget build(BuildContext context) {


    return Container(

      margin: const EdgeInsets.only(bottom:15),

      decoration: BoxDecoration(

        color: AppColors.cardBg,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: AppColors.cardBorder,
        ),

      ),


      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [


                Text(
                  "Report #${report.reportId}",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize:18,
                    fontWeight:FontWeight.w800,
                  ),
                ),



                Container(

                  padding: const EdgeInsets.symmetric(
                    horizontal:12,
                    vertical:5,
                  ),

                  decoration: BoxDecoration(

                    color: _color(report.color)
                        .withOpacity(.15),

                    borderRadius:
                    BorderRadius.circular(20),

                  ),


                  child: Text(

                    report.color.toString()
                        .toUpperCase(),

                    style: TextStyle(

                      color:_color(report.color),

                      fontSize:11,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                )

              ],
            ),



            const SizedBox(height:15),




            _item(
              "📅 Date",
              _formatDate(report.date),
            ),


            _item(
              "📍 Location",
              report.address ?? "Unknown",
            ),



            _item(
              "🌊 Zone",
              report.zone?.name ?? "Unknown",
            ),



            _item(
              "🛥 Description",
              report.description ?? "No description",
            ),



            _item(
              "👥 People",
              "${report.numberOfPeople ?? 0}",
            ),



            _item(
              "👤 Reporter",
              report.name ?? "Anonymous",
            ),



            _item(
              "📞 Phone",
              report.phone ?? "Not provided",
            ),



            const SizedBox(height:12),



            if(report.photo != null)

              ClipRRect(

                borderRadius:
                BorderRadius.circular(14),

                child: Image.network(

                  report.photo,

                  height:170,

                  width:double.infinity,

                  fit:BoxFit.cover,


                  errorBuilder:
                      (_,__,___){

                    return Container(

                      height:170,

                      alignment:
                      Alignment.center,

                      color:
                      Colors.black12,

                      child:
                      const Text(
                        "Image unavailable",
                      ),

                    );
                  },

                ),
              ),



          ],

        ),

      ),

    );

  }




  Widget _item(String title,String value){

    return Padding(

      padding:
      const EdgeInsets.only(bottom:8),

      child:Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children:[


          SizedBox(

            width:110,

            child:Text(

              title,

              style:
              const TextStyle(

                color:
                AppColors.dim,

                fontSize:12,

                fontWeight:
                FontWeight.w600,

              ),

            ),

          ),



          Expanded(

            child:Text(

              value,

              style:
              const TextStyle(

                color:
                AppColors.white,

                fontSize:13,

              ),

            ),

          )

        ],

      ),

    );

  }





  Color _color(String? color){

    switch(color){

      case "red":
        return Colors.red;

      case "orange":
        return Colors.orange;

      case "green":
        return Colors.green;

      default:
        return Colors.blue;

    }

  }




  String _formatDate(String? date){

    if(date == null) return "";

    final d = DateTime.parse(date);

    return "${d.day}/${d.month}/${d.year} "
        "${d.hour}:${d.minute}";

  }

}