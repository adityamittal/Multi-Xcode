/***************************************************************************
 * Authors:       soni.rajneesh@gmail.com
 * Synopsys:
 *
 * This file contains the implementation for the Creation of the Mpegts Segments
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

    int segmentNumber;

    gst_init (&argc, &argv);

    if (argc != 2) {
	g_print ("usage: %s <Segment Number>\n", argv[1]);
	return -1;
    }

    sscanf(argv[1],"%d", &(segmentNumber));

    g_print("Segment No:: %d \n",segmentNumber);

    loop = g_main_loop_new (NULL, FALSE);

    /* Starting the Pipeline to Create TS Segments */

    myPipeline = g_strdup_printf("filesrc location=vid_%d.gdp ! gdpdepay ! video/x-h264 ! mpegtsmux name=mux ! filesink location=mux_%d.ts filesrc location=aud_%d.gdp ! gdpdepay ! audio/mpeg ! mux.  ", segmentNumber, segmentNumber, segmentNumber);

    pipeline = gst_parse_launch (myPipeline, &error);
    if (!pipeline) {
	g_print ("Parse error: %s\n", error->message);
	exit (1);
    }
    
    gst_element_set_state (pipeline, GST_STATE_PLAYING);

    bus = gst_element_get_bus (pipeline);
    gst_bus_add_watch (bus, bus_call, loop);

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
