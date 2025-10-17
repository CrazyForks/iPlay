package top.ourfor.app.iplay.api.webdav;

import static top.ourfor.app.iplay.module.Bean.XGET;

import android.net.Uri;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Consumer;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import top.ourfor.app.iplay.api.file.File;
import top.ourfor.app.iplay.api.file.FileProvider;
import top.ourfor.app.iplay.api.file.FileType;
import top.ourfor.app.iplay.bean.IJSONAdapter;
import top.ourfor.app.iplay.model.WebDavSiteModel;
import top.ourfor.app.iplay.model.drive.WebDAVModel;
import top.ourfor.app.iplay.util.HTTPUtil;
import top.ourfor.app.iplay.util.PathUtil;

@Slf4j
@NoArgsConstructor
@AllArgsConstructor
public class WebDavFileProvider implements FileProvider {

    WebDavFileApi api = null;

    public WebDavFileProvider(WebDAVModel drive) {
        api = WebDavFileApi.builder()
                .serverUrl(drive.getServerUrl())
                .username(drive.getUsername())
                .password(drive.getPassword())
                .build();
    }

    @Override
    public void listFiles(String path, Consumer<List<File>> completion) {
        api.listFiles(path, files -> {
            val result = new CopyOnWriteArrayList<File>();
            if (!path.equals("/")) {
                result.add(File.builder()
                        .name("..")
                        .path(PathUtil.parent(path))
                        .size(-1L)
                        .type(FileType.LINK)
                        .build());
            }
            result.addAll(files);
            completion.accept(result);
        });
    }

    @Override
    public void link(File file, Consumer<String> completion) {
        val source = PathUtil.of(api.serverUrl, file.getPath());
        if (source.endsWith(".strm")) {
            read(file.getPath(), (res) -> {
                if (res instanceof String content) {
                    val url = content.trim();
                    completion.accept(formatUrl(url));
                }
            });
        } else {
            val url = formatUrl(source);
            completion.accept(url);
        }
    }

    String formatUrl(String source) {
        val auth = api.username + "@" + api.password + ":";
        val protocols = List.of("https://", "http://");
        var url = source;
        for (val protocol : protocols) {
            if (source.startsWith(protocol)) {
                url = protocol + auth + source.substring(protocol.length());
                break;
            }
        }
        return url;
    }

    @Override
    public void read(String path, Consumer<Object> completion) {
        WebDavSiteModel site = WebDavSiteModel.builder()
                .server(api.serverUrl)
                .username(api.username)
                .password(api.password)
                .build();
        val api = WebdavApi.builder()
                .site(site)
                .build();
        api.bindSite(site);
        api.readFromFile(path, completion);
    }

    @Override
    public void write(String path, String content, Consumer<Boolean> completion) {
        WebDavSiteModel site = WebDavSiteModel.builder()
                .server(api.serverUrl)
                .username(api.username)
                .password(api.password)
                .build();
        val api = WebdavApi.builder()
                .site(site)
                .build();
        api.createDirectory(PathUtil.parent(path), result -> {
            if (result == null) {
                completion.accept(false);
                return;
            }
            if (result instanceof Boolean) {
                val success = (Boolean) result;
                if (success) {
                    api.writeToFile(path, content, r -> {
                        log.info("write file result: {}", r);
                        if (r instanceof Boolean flag) {
                            completion.accept(flag);
                            return;
                        }
                        completion.accept(false);
                    });
                    return;
                }
            }
            completion.accept(false);
        });
    }
}
