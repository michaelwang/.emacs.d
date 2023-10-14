;; lisp/init-elpa.el用于存放Elpa和Package初始化

;; 定义是否显示emacs的启动界面
;;(setq inhibit-startup-screen t)


;; 定义是否启用国内的镜像下载插件
(setq package-archives
      '(("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
        ("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("org" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/org/")))

;;(setq package-check-signature t) 


;; 初始化软件包管理器
(require 'package)
(unless (bound-and-true-p package--initialized)
    (package-initialize))


;; 刷新软件源索引
(unless package-archive-contents
    (package-refresh-contents))


;; 第一个扩展插件：use-package，用来批量统一管理软件包
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))

(unless (package-installed-p 'benchmark-init)
    (package-refresh-contents)
    (package-install 'benchmark-init))

;;(use-package benchmark-init
;;             :init (benchmark-init/activate)
;;             :hook (after-init . benchmark-init/deactivate))


;; 删除当前行
;;(unless (package-installed-p 'crux)
;;    (package-refresh-contents)
;;    (package-install 'crux))

;;(use-package crux 
;;             :bind ("C-c k" . crux-smart-kill-line))


;; 文本编辑之行/区域上下移动
(unless (package-installed-p 'drag-stuff)
    (package-refresh-contents)
    (package-install 'drag-stuff))

(use-package drag-stuff
             :bind (("C-c g u" . drag-stuff-up)
                    ("C-c g d" . drag-stuff-down)))

;; 删除连续的空白
(unless (package-installed-p 'hungry-delete)
    (package-refresh-contents)
    (package-install 'hungry-delete))

(use-package hungry-delete
  :bind (("C-c DEL" . hungry-delete-backward)
         ("C-c d" . hungry-delete-forward)))


;; ivy
(unless (package-installed-p 'ivy)
    (package-refresh-contents)
    (package-install 'ivy))

(use-package ivy
  :defer 1
  :demand
  :hook (after-init . ivy-mode)
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
	ivy-initial-inputs-alist nil
	ivy-count-format "(%d/%d) "
	enable-recursive-minibuffers t
	ivy-re-builders-alist '((t . ivy--regex-ignore-order))
	)
)


(unless (package-installed-p 'counsel)
    (package-refresh-contents)
    (package-install 'counsel))

(use-package counsel
  :after (ivy)
  :bind (("M-x" . counsel-M-x)
         ("C-c g" . counsel-git)
	 ("C-c j" . counsel-git-grep)
	 ("C-c l" . counsel-locate)
	 ("C-c J" . counsel-file-jump)))


(unless (package-installed-p 'swiper)
    (package-refresh-contents)
    (package-install 'swiper))

(use-package swiper
  :after (ivy)
  :bind (("C-s" . swiper)
	 ("C-r" . swiper-isearch-backward))
  :config (setq swiper-action-recenter t
		swiper-include-line-number-in-search t))



(unless (package-installed-p 'company)
    (package-refresh-contents)
    (package-install 'company))

(use-package swiper
  :hook (after-init . global-company-mode)
  :config (setq company-minimum-prefix-length 1
	        company-show-quick-access t))

(unless (package-installed-p 'flymake)
  (package-refresh-contents)
  (package-install 'flymake))

(use-package flymake
  :hook (prog-mode . flymake-mode)
  :config
  (global-set-key (kbd "M-n") #'flymake-goto-next-error)
  (global-set-key (kbd "M-p") #'flymake-goto-prev-error))


(unless (package-installed-p 'ace-window)
  (package-refresh-contents)
  (package-install 'ace-window))

(use-package ace-window
  :bind (("M-o" . 'ace-window)))

(unless (package-installed-p 'eglot)
  (package-refresh-contents)
  (package-install 'eglot))

;;(with-eval-after-load 'eglot
  ;; Define said class and its methods
;;  (cl-defmethod eglot-execute-command
;;    (_server (_cmd (eql java.apply.workspaceEdit)) arguments)
;;    "Eclipse JDT breaks spec and replies with edits as arguments."
;;    (mapc #'eglot--apply-workspace-edit arguments)))

(defvar +eglot/initialization-options-map (make-hash-table :size 5))
(with-eval-after-load 'eglot
  ;; Define said class and its methods
    
  (defclass eglot-eclipse-jdt (eglot-lsp-server) ()
    :documentation "Eclipse's Java Development Tools Language Server.")
  ;; 为了解决java的lsp服务器jdtls不支持java.apply.workspaceEdit命令
  ;; 利用了elisp中超类中的方法复写机制，解决该问题 目前jdtls官方认定该问题为了保证兼容性不再修复该问题具体参考
  ;; https://github.com/eclipse/eclipse.jdt.ls/issues/376
  ;; https://github.com/joaotavora/eglot/discussions/888
  (cl-defmethod eglot-execute-command
    (server (command (eql java.apply.workspaceEdit)) arguments)
    "Eclipse JDT breaks spec and replies with edits as arguments."
    (mapc #'eglot--apply-workspace-edit arguments))
)



;; (add-to-list 'eglot-server-programs '(js-mode . ("vscode-eslint-language-server" "--stdio")))

(with-eval-after-load 'eglot
  ;; Define said class and its methods
   (message "file : %s" (expand-file-name (locate-user-emacs-file "cache/eclipse-java-google-style.xml")))
   (puthash 'java-mode
           `(:settings
             (:java
              (:configuration
               (:runtime [(:name "JavaSE-17" :path "/usr/lib/jvm/java-1.17.0-openjdk-amd64" :default t)
                          (:name "JavaSE-8" :path "/usr/lib/jvm/java-1.8.0-openjdk-amd64")])
               :format (:settings (:url ,(expand-file-name (locate-user-emacs-file "cache/eclipse-java-google-style.xml"))
                                        :profile "GoogleStyle")))))
	   +eglot/initialization-options-map)
   (puthash 'java-ts-mode
           `(:settings
             (:java
              (:configuration
               (:runtime [(:name "JavaSE-17" :path "/usr/lib/jvm/java-1.17.0-openjdk-amd64" :default t)
                          (:name "JavaSE-8" :path "/usr/lib/jvm/java-1.8.0-openjdk-amd64")])
               :format (:settings (:url ,(expand-file-name (locate-user-emacs-file "cache/eclipse-java-google-style.xml"))
                                        :profile "GoogleStyle")))))
	   +eglot/initialization-options-map)
   
   (cl-defmethod eglot-initialization-options (server)
    (message "server 1: %s"  (eglot--major-modes server))
    (message "server 2: %s" (gethash 'java-mode +eglot/initialization-options-map))
    (message "server 3: %s" +eglot/initialization-options-map)    
    (if-let ((init-options (gethash 'java-mode +eglot/initialization-options-map)))
        init-options
      eglot--{})
    (if-let ((init-options (gethash 'java-ts-mode +eglot/initialization-options-map)))
        init-options
      eglot--{}))

    (defclass eglot-vls (eglot-lsp-server) ()
      :documentation "Vue Language Server.")
    (cl-defmethod eglot-initialization-options ((server eglot-vls))
     "Passes through required vetur initialization options to VLS."
     '(:vetur
       (:completion
	(:autoImport t :useScaffoldSnippets t :tagCasing "kebab")
	:grammar
	(:customBlocks
	 (:docs "md" :i18n "json"))
	:validation
	(:template t :style t :script t)
	:format
	(:options
	 (:tabSize 2 :useTabs :json-false)
	 :defaultFormatter
	 (:html "prettyhtml" :css "prettier" :postcss "prettier" :scss "prettier" :less "prettier" :stylus "stylus-supremacy" :js "prettier" :ts "prettier")
	 :defaultFormatterOptions
	 (:js-beautify-html
	  (:wrap_attributes "force-expand-multiline")
	  :prettyhtml
	  (:printWidth 100 :singleQuote :json-false :wrapAttributes :json-false :sortAttributes :json-false))
	 :styleInitialIndent :json-false :scriptInitialIndent :json-false)
	:trace
	(:server "verbose")
	:dev
	(:vlsPath ""))
    ))
   
)

(use-package eglot  
  :config
  ;;;(foo-mode 1)
  (add-to-list 'eglot-server-programs
	       `(java-mode "jdtls"
                           "-configuration" ,(expand-file-name "cache/language-server/java/jdtls/config_linux" user-emacs-directory)
                           "-data" , (expand-file-name (md5 (project-root (eglot--current-project)))
						       (locate-user-emacs-file
							"eglot-eclipse-jdt-cache")))

	       `((js-mode . ("vscode-eslint-language-server" "--stdio")))	       
	       ;;;`(vue-mode . (eglot-vls . ("vls" "--stdio")))
	       )
  ;; configure clangd for c++ and c
  (when-let* ((clangd (seq-find #'executable-find '("clangd")))
    ;; this has to match the tool string in compile-commands.json
    ;; clangd will then use these tools to get system header paths
              (init-args "--enable-config"))
    (add-to-list 'eglot-server-programs
                 `((c++-mode c-mode) ,clangd ,init-args)))
  
  :hook ((java-mode) . eglot-ensure)
  :hook ((c-mode) . eglot-ensure)
  :hook ((python-mode) . eglot-ensure)    
  :bind ("C-c e f" . eglot-ensure)
  :bind ("C-c c a" . eglot-code-actions)
  :bind ("C-c c r" . eglot-rename)  
)
	       ;; `(vue-mode "vls" "--stdio")))


;;; Setup specific to the Eclipse JDT setup in case one can't use the simpler 'jdtls' script

;; todo 暂时不使用 等后面再进行调试 目前发现和eglot 1.10版本有冲突 参考https://github.com/yveszoundi/eglot-java/issues/8
;;(unless (package-installed-p 'eglot-java)
;;  (package-refresh-contents)
;;  (package-install 'eglot-java))

(unless (package-installed-p 'go-mode)
  (package-refresh-contents)
  (package-install 'go-mode))

;;(defun project-find-go-module (dir)
;;  (when-let ((root (locate-dominating-file dir "go.mod")))
;;    (cons 'go-module root)))

;;(cl-defmethod project-root ((project (head go-module)))
;;  (cdr project))

(defun eglot-format-buffer-on-save ()
  (add-hook 'before-save-hook #'eglot-format-buffer -10 t))

;;(add-hook 'project-find-functions #'project-find-go-module)
(add-hook 'go-mode-hook #'eglot-format-buffer-on-save)
(add-hook 'java-mode-hook #'eglot-format-buffer-on-save)

;; eglot依赖project组件寻找工程文件 但是会存在两个问题
;; 1. 对于多模块的工程（java或者go）不能正确识别出工程的根目录
;; 2. 对于没有VC控制文件的工程 不能识别出项目的根目录
;; 通过如下的代码可以解决问题1. 在项目的根目录下手动创建.projectile 文件可以解决问题2
;; https://zerokspot.com/weblog/2019/11/27/eglot-projects-not-in-vcs-root/
;; begin 
(unless (package-installed-p 'project)
  (package-refresh-contents)
  (package-install 'project))

(unless (package-installed-p 'projectile)
  (package-refresh-contents)
  (package-install 'projectile))

(defun my-projectile-project-find-function (dir)
  (let ((root (projectile-project-root dir)))
    (and root (cons 'transient root))))

(projectile-mode t)

(with-eval-after-load 'project
  (add-to-list 'project-find-functions 'my-projectile-project-find-function))
;; end 

(add-hook 'go-mode-hook 'eglot-ensure)



;; snippt
(unless (package-installed-p 'yasnippet)
  (package-refresh-contents)
  (package-install 'yasnippet))

(unless (package-installed-p 'java-snippets)
  (package-refresh-contents)
  (package-install 'java-snippets))

(require 'yasnippet)
(yas-global-mode 1)
;;

;; 第一个扩展插件：use-package，用来批量统一管理软件包
(unless (package-installed-p 'vue-mode)
    (package-refresh-contents)
    (package-install 'vue-mode))


;; install git
;;(unless (package-installed-p 'git)
;;  (package-refresh-contents)
;;  (package-install 'git))

;;(require 'git) //this package is to old, can not run 


(unless (package-installed-p 'magit)
  (package-refresh-contents)
  (package-install 'magit))

(require 'magit) 

(with-eval-after-load 'magit-mode
  (add-hook 'after-save-hook 'magit-after-save-refresh-status t))

(setq dired-dwim-target t)


;; install typescript package
(unless (package-installed-p 'typescript-mode)
  (package-refresh-contents)
  (package-install 'typescript-mode))


;; Adapted from https://github.com/emacs-typescript/typescript.el/issues/4#issuecomment-873485004
(use-package typescript-mode
  :ensure t
  :init
  (define-derived-mode typescript-tsx-mode typescript-mode "tsx")
  :config
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescript-tsx-mode)))


(use-package eglot
  :ensure t

  :config
  (add-to-list 'eglot-server-programs
               '(svelte-mode . ("svelteserver" "--stdio")))

  (put 'typescript-tsx-mode 'eglot-language-id "typescriptreact")

  (defun akirak/eglot-setup-buffer ()
    (if (eglot-managed-p)
        (add-hook 'before-save-hook #'eglot-format-buffer nil t)
      (remove-hook 'before-save-hook #'eglot-format-buffer t)))

  :hook
  (eglot-managed-mode . akirak/eglot-setup-buffer))

(add-hook 'typescript-tsx-mode-hook 'eglot-ensure)

(provide 'init-elpa)
