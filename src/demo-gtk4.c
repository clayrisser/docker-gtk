#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer user_data) {
  GtkWidget *window;
  GtkWidget *image;
  window = gtk_application_window_new(app);
  image = gtk_image_new_from_file("cat.jpg");
  gtk_window_set_child(GTK_WINDOW(window), image);
  gtk_window_set_title(GTK_WINDOW(window), "Docker GTK");
  gtk_window_set_default_size(GTK_WINDOW(window), 200, 200);
  gtk_window_present(GTK_WINDOW(window));
}

int main(int argc, char **argv) {
  GtkApplication *app;
  int status;
  app = gtk_application_new("com.rock8s.DockerGtk4", G_APPLICATION_DEFAULT_FLAGS);
  g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
  status = g_application_run(G_APPLICATION(app), argc, argv);
  g_object_unref(app);
  return status;
}
