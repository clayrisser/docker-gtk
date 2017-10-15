#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer user_data) {
  GtkWidget *window;
  GtkWidget *image;
  GtkWidget *event_box;
  window = gtk_application_window_new(app);
  image = gtk_image_new_from_file("cat.jpg");
  gtk_container_add(GTK_CONTAINER(window), image);
  gtk_window_set_title(GTK_WINDOW(window), "Docker GTK");
  gtk_window_set_default_size(GTK_WINDOW(window), 200, 200);
  gtk_widget_show_all(window);
}

int main(int argc, char **argv) {
  GtkApplication *app;
  app = gtk_application_new("com.jamrizzi.docker-gtk", G_APPLICATION_FLAGS_NONE);
  g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
  g_application_run(G_APPLICATION(app), argc, argv);
  g_object_unref(app);
}
