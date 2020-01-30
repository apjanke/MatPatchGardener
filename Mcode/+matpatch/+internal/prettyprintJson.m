function out = prettyprintJson(jsonTxt)

gson = com.google.gson.GsonBuilder;
gson = gson.setPrettyPrinting().create();
jp = com.google.gson.JsonParser;
je = jp.parse(jsonTxt);
out = string(gson.toJson(je));

end
