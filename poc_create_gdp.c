/***************************************************************************
 * Authors:       soni.rajneesh@gmail.com
 * Synopsys:
 *
 * This file contains the implementation for the Creation of the GDP Segments
 * 
 * Copyright 2013
 * The material in this file is subject to copyright. It may not be used,
 * copied or transferred by any means without the prior written approval
 *****************************************************************************/

#include <gst/gst.h>
#include <glib.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>

static gboolean
bus_call (GstBus *bus,
	GstMessage *msg,
	gpointer data)
{
    GMainLoop *loop = (GMainLoop *) data;
    switch (GST_MESSAGE_TYPE (msg)) {
	case GST_MESSAGE_EOS:
	    g_print ("End of stream \n");
            g_main_loop_quit (loop);
	    break;
	case GST_MESSAGE_ERROR: {
				    gchar *debug;
				    GError *error;
				    gst_message_parse_error (msg, &error, &debug);
				    g_free (debug);
				    g_printerr ("Error: %s\n", error->message);
				    g_error_free (error);
				    g_main_loop_quit (loop);
				    break;
				}
	case GST_MESSAGE_STATE_CHANGED:
				{
				    GstState l_OldState, l_NewState, l_PendingState;
				    gst_message_parse_state_changed (
					    msg,
					    &l_OldState,
					    &l_NewState,
					    &l_PendingState);
				    //						g_print ("Element %s changed state from %s to %s.\n",
				    //								GST_OBJECT_NAME (msg->src),
				    //								gst_element_state_get_name (l_OldState),
				    //								gst_element_state_get_name (l_NewState));

				}
				break;           
	default:
				break;
    }

    return TRUE;
}

int
main (int argc, char *argv[])
{

    GError *error = NULL;
    gchar *myPipeline;

    GMainLoop *loop;
    GstElement *pipeline;
    GstBus *bus;

    float segmentStartTime;
    float segmentEndTime;
    int segmentNumber;

    gst_init (&argc, &argv);

    if (argc != 5) {
	g_print ("usage: %s <filename> %s <Segment Start Time> %s <Segment End Time> %s <Segment Number>\n", argv[1],argv[2],argv[3],argv[4]);
	return -1;
    }

    sscanf(argv[2],"%f", &(segmentStartTime));
    sscanf(argv[3],"%f", &(segmentEndTime));
    sscanf(argv[4],"%d", &(segmentNumber));

    g_print("FileName:: %s StartTime:: %f Segment Endtime :: %f \n",argv[1],segmentStartTime,segmentEndTime);

    if (segmentStartTime < 0 || segmentEndTime <= 0)
    {
	g_print("Incorrect Start or End Time for Segments \n");
	return -1;
    }

    if(segmentStartTime >= segmentEndTime)
    {
	g_print("Segment Start time can't be greater than End time \n");
	return -1;
    }

    loop = g_main_loop_new (NULL, FALSE);

    /* Starting the Pipeline for the Segment.. Seeking to the Segment Duration */
    /* Gstreamer Pushes different Pipeline on different Cores based on the CPU Usage */

    myPipeline = g_strdup_printf("filesrc location=%s ! decodebin2 name=d ! queue max-size-time=0 max-size-bytes=0 ! ffmpegcolorspace ! video/x-raw-yuv !  x264enc profile=1 cabac=false bitrate=1024 speed-preset=1 byte-stream=true !  gdppay ! filesink location=vid_%d.gdp d. ! queue max-size-time=0 max-size-bytes=0 ! audioconvert ! audio/x-raw-int ! ffenc_aac bitrate=96000 ! gdppay ! filesink location=aud_%d.gdp  ", argv[1] , segmentNumber, segmentNumber);

    pipeline = gst_parse_launch (myPipeline, &error);
    if (!pipeline) {
	g_print ("Parse error: %s\n", error->message);
	exit (1);
    }
    
    /* Waiting for Pipeline to go to PAUSED state */
    gst_element_set_state (pipeline, GST_STATE_PAUSED);
    gst_element_get_state (pipeline, NULL, NULL,GST_CLOCK_TIME_NONE);

    bus = gst_element_get_bus (pipeline);
    gst_bus_add_watch (bus, bus_call, loop);

    /* Seek the pipeline to the Desired Start Position */
    if (!gst_element_seek (pipeline, 1.0, GST_FORMAT_TIME, GST_SEEK_FLAG_ACCURATE ,GST_SEEK_TYPE_SET, segmentStartTime * GST_SECOND,GST_SEEK_TYPE_SET, segmentEndTime * GST_SECOND))

    {
	g_print ("Seek failed!\n");

    }else{
	printf("Seek succedded %f %f \n",segmentStartTime,segmentEndTime);
	gst_element_set_state (pipeline, GST_STATE_PLAYING);
    }

    g_main_loop_run (loop);

    g_print("Freeing the Gstreamer Pipeline \n");

    /* Confirm Pipeline goes to NULL State */
    gst_element_set_state (pipeline, GST_STATE_NULL);
    gst_element_get_state (pipeline, NULL, NULL,GST_CLOCK_TIME_NONE);
    gst_object_unref (pipeline);
    gst_object_unref (bus);

    g_main_loop_quit(loop);
    return 0;
}

// vim: filetype=c:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=99 :
