
;; packages:
;; $ guix build -K --target=riscv64-linux-gnu -f guix-on-vf2.scm

;; image:
;; $ guix system image -K --target=riscv64-linux-gnu guix-on-vf2.scm
;; $ guix system image -K -t tarball --target=riscv64-linux-gnu guix-on-vf2.scm

(define-module (guix-on-vf2)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (guix platforms riscv)

  #:use-module (gnu packages cross-base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages python)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages firmware)
  #:use-module (gnu packages bootloaders)

  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages certs)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (srfi srfi-26)
  )
;; not exported
(define make-opensbi-package (@@ (gnu packages firmware) make-opensbi-package))
(define u-boot-bootloader (@@ (gnu bootloader u-boot) u-boot-bootloader))

(define linux-configs
  '("CONFIG_WERROR=y"
    "CONFIG_SYSVIPC=y"
    "CONFIG_NO_HZ_IDLE=y"
    "CONFIG_HIGH_RES_TIMERS=y"
    "CONFIG_PSI=y"
    "CONFIG_IKCONFIG=y"
    "CONFIG_IKCONFIG_PROC=y"
    "CONFIG_CGROUPS=y"
    "CONFIG_CGROUP_SCHED=y"
    "CONFIG_CGROUP_PIDS=y"
    "CONFIG_CGROUP_CPUACCT=y"
    "CONFIG_NAMESPACES=y"
    "CONFIG_BLK_DEV_INITRD=y"
    "CONFIG_EXPERT=y"
    "CONFIG_PERF_EVENTS=y"
    "CONFIG_SOC_STARFIVE=y"
    "CONFIG_ERRATA_SIFIVE=y"
    "CONFIG_NONPORTABLE=y"
    "CONFIG_SMP=y"
    "CONFIG_HIBERNATION=y"
    "CONFIG_CPU_IDLE=y"
    "CONFIG_RISCV_SBI_CPUIDLE=y"
    "CONFIG_CPU_FREQ=y"
    "CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y"
    "CONFIG_CPU_FREQ_GOV_POWERSAVE=y"
    "CONFIG_CPU_FREQ_GOV_USERSPACE=y"
    "CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y"
    "CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y"
    "CONFIG_CPUFREQ_DT=y"
    "CONFIG_JUMP_LABEL=y"
    "CONFIG_MODULES=y"
    "CONFIG_MODULE_UNLOAD=y"
    "CONFIG_MODULE_COMPRESS_ZSTD=y"
    "CONFIG_BLK_WBT=y"
    "CONFIG_PARTITION_ADVANCED=y"
    "CONFIG_KSM=y"
    "CONFIG_NET=y"
    "CONFIG_PACKET=y"
    "CONFIG_UNIX=y"
    "CONFIG_INET=y"
    "CONFIG_IP_ADVANCED_ROUTER=y"
    "CONFIG_IP_MULTIPLE_TABLES=y"
    "CONFIG_IP_PNP=y"
    "CONFIG_INET_DIAG=m"
    "CONFIG_IPV6_MULTIPLE_TABLES=y"
    "CONFIG_PCI=y"
    "CONFIG_PCIEPORTBUS=y"
    "CONFIG_PCI_HOST_GENERIC=y"
    ;;"CONFIG_PCIE_STARFIVE_HOST=y"
    "CONFIG_DEVTMPFS=y"
    "CONFIG_DEVTMPFS_MOUNT=y"
    ;;"CONFIG_FW_LOADER=m"
    "CONFIG_EFI_DISABLE_RUNTIME=y"
    "CONFIG_MTD=y"
    "CONFIG_MTD_SPI_NOR=y"
    "CONFIG_ZRAM=y"
    "CONFIG_ZRAM_MEMORY_TRACKING=y"
    "CONFIG_BLK_DEV_LOOP=y"
    "CONFIG_BLK_DEV_LOOP_MIN_COUNT=1"
    "CONFIG_BLK_DEV_NVME=y"
    "CONFIG_SCSI=y"
    "CONFIG_BLK_DEV_SD=y"
    "CONFIG_BLK_DEV_SR=y"
    "CONFIG_NETDEVICES=y"
    "CONFIG_STMMAC_ETH=y"
    "CONFIG_DWMAC_DWC_QOS_ETH=y"
    "CONFIG_DWMAC_STARFIVE=y"
    "CONFIG_MICROCHIP_PHY=y"
    "CONFIG_MOTORCOMM_PHY=y"
    "CONFIG_SERIAL_8250=y"
    "CONFIG_SERIAL_8250_CONSOLE=y"
    "CONFIG_SERIAL_8250_DW=y"
    "CONFIG_SERIAL_OF_PLATFORM=y"
    "CONFIG_HW_RANDOM=y"
    "CONFIG_HW_RANDOM_JH7110=y"
    "CONFIG_I2C_CHARDEV=y"
    "CONFIG_I2C_DESIGNWARE_PLATFORM=y"
    "CONFIG_SPI=y"
    "CONFIG_SPI_CADENCE_QUADSPI=y"
    "CONFIG_SPI_PL022=y"
    "CONFIG_GPIOLIB_FASTPATH_LIMIT=128"
    "CONFIG_GPIO_SYSFS=y"
    "CONFIG_POWER_RESET=y"
    "CONFIG_POWER_RESET_GPIO_RESTART=y"
    "CONFIG_SENSORS_SFCTEMP=y"
    "CONFIG_THERMAL=y"
    "CONFIG_CPU_THERMAL=y"
    "CONFIG_THERMAL_EMULATION=y"
    "CONFIG_WATCHDOG=y"
    "CONFIG_MFD_AXP20X_I2C=y"
    "CONFIG_REGULATOR=y"
    "CONFIG_REGULATOR_AXP20X=y"
    "CONFIG_MEDIA_SUPPORT=y"
    "CONFIG_V4L_PLATFORM_DRIVERS=y"
    "CONFIG_VIDEO_CADENCE_CSI2RX=y"
    "CONFIG_VIDEO_IMX219=y"
    "CONFIG_DRM=y"
    ;;"CONFIG_DRM_VERISILICON=y"
    ;;"CONFIG_DRM_VERISILICON_STARFIVE_HDMI=y"
    "CONFIG_BACKLIGHT_CLASS_DEVICE=y"
    "CONFIG_SOUND=y"
    "CONFIG_SND=y"
    "CONFIG_SND_SOC=y"
    "CONFIG_SND_DESIGNWARE_I2S=y"
    "CONFIG_SND_SOC_STARFIVE=y"
    ;;"CONFIG_SND_SOC_JH7110_PWMDAC=y"
    "CONFIG_SND_SOC_JH7110_TDM=y"
    "CONFIG_SND_SOC_WM8960=y"
    "CONFIG_SND_SIMPLE_CARD=y"
    "CONFIG_USB=y"
    "CONFIG_USB_XHCI_HCD=y"
    "CONFIG_USB_EHCI_HCD=y"
    "CONFIG_USB_EHCI_HCD_PLATFORM=y"
    "CONFIG_USB_OHCI_HCD=y"
    "CONFIG_USB_OHCI_HCD_PLATFORM=y"
    "CONFIG_USB_STORAGE=y"
    "CONFIG_USB_UAS=y"
    "CONFIG_USB_CDNS_SUPPORT=y"
    "CONFIG_USB_CDNS3=y"
    "CONFIG_USB_CDNS3_GADGET=y"
    "CONFIG_USB_CDNS3_HOST=y"
    "CONFIG_USB_CDNS3_STARFIVE=y"
    "CONFIG_USB_GADGET=y"
    "CONFIG_USB_CONFIGFS=y"
    "CONFIG_USB_CONFIGFS_F_FS=y"
    "CONFIG_MMC=y"
    "CONFIG_MMC_DW=y"
    "CONFIG_MMC_DW_STARFIVE=y"
    "CONFIG_DMADEVICES=y"
    "CONFIG_AMBA_PL08X=y"
    "CONFIG_DW_AXI_DMAC=y"
    "CONFIG_DMATEST=y"
    "CONFIG_STAGING=y"
    "CONFIG_STAGING_MEDIA=y"
    ;;"CONFIG_VIDEO_STARFIVE_CAMSS=y"
    "CONFIG_CLK_STARFIVE_JH7110_AON=y"
    "CONFIG_CLK_STARFIVE_JH7110_STG=y"
    "CONFIG_CLK_STARFIVE_JH7110_ISP=y"
    "CONFIG_CLK_STARFIVE_JH7110_VOUT=y"
    "CONFIG_SIFIVE_CCACHE=y"
    "CONFIG_PWM=y"
    ;;"CONFIG_PWM_OCORES=y"
    "CONFIG_PHY_STARFIVE_JH7110_DPHY_RX=y"
    "CONFIG_PHY_STARFIVE_JH7110_PCIE=y"
    "CONFIG_PHY_STARFIVE_JH7110_USB=y"
    "CONFIG_EXT4_FS=y"
    "CONFIG_BTRFS_FS=y"
    "CONFIG_BTRFS_FS_POSIX_ACL=y"
    "CONFIG_FANOTIFY=y"
    "CONFIG_AUTOFS_FS=y"
    "CONFIG_MSDOS_FS=y"
    "CONFIG_VFAT_FS=y"
    "CONFIG_FAT_DEFAULT_UTF8=y"
    "CONFIG_EXFAT_FS=y"
    "CONFIG_NTFS_FS=y"
    "CONFIG_NTFS_RW=y"
    "CONFIG_PROC_KCORE=y"
    "CONFIG_PROC_CHILDREN=y"
    "CONFIG_TMPFS=y"
    "CONFIG_TMPFS_POSIX_ACL=y"
    "CONFIG_EFIVAR_FS=y"
    "CONFIG_JFFS2_FS=y"
    "CONFIG_NFS_FS=y"
    "CONFIG_NFS_V4=y"
    "CONFIG_NFS_V4_1=y"
    "CONFIG_NFS_V4_2=y"
    "CONFIG_ROOT_NFS=y"
    "CONFIG_NLS_DEFAULT=\"iso8859-15\""
    "CONFIG_NLS_CODEPAGE_437=y"
    "CONFIG_NLS_ISO8859_15=y"
    "CONFIG_LSM=\"\""
    "CONFIG_CRYPTO_ZSTD=y"
    "CONFIG_STRIP_ASM_SYMS=y"
    "CONFIG_DEBUG_SECTION_MISMATCH=y"
    "CONFIG_DEBUG_FS=y"
    "CONFIG_DEBUG_RODATA_TEST=y"
    "CONFIG_DEBUG_WX=y"
    "CONFIG_SOFTLOCKUP_DETECTOR=y"
    "CONFIG_WQ_WATCHDOG=y"
    "CONFIG_STACKTRACE=y"
    "CONFIG_RCU_CPU_STALL_TIMEOUT=60"))


(define-public opensbi-vf2
  (let ((base (make-opensbi-package "generic" "opensbi-vf2")))
    (package
      (inherit base)
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:make-flags flags)
          `(append ,flags (list "FW_TEXT_START=0x40000000"))))))))

(define-public u-boot-vf2
  (let ((base (make-u-boot-package
               "starfive_visionfive2" "riscv64-linux-gnu"
               #:append-description "This is U-boot for the VisionFive2.")))
    (package
      (inherit base)
      (name "u-boot-vf2")
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'unpack 'set-environment
                (lambda* (#:key inputs #:allow-other-keys)
                  (setenv "OPENSBI"
                          (search-input-file inputs "fw_dynamic.bin"))))))))
      (inputs
       (modify-inputs (package-inputs base)
         (append opensbi-vf2))))))

(define-public linux-vf2
  (let ((base (customize-linux
               #:linux linux-libre-6.6
               #:source linux-libre-6.6-pristine-source
               #:configs linux-configs)))
    (package
      (inherit base)
      (name "linux-vf2")
      (native-inputs
       (cons* `("python" ,python-wrapper)
              `("python3" ,python-3)
              `("zstd" ,zstd)
              (package-native-inputs base))))))

(define install-vf2-u-boot ;; FIXME
  #~(lambda (bootloader root-index image)
      (let ((u-boot (string-append bootloader
                                   "/libexec/u-boot-sunxi-with-spl.bin")))
        (write-file-on-device u-boot (stat:size (stat u-boot))
                              image (* 8 1024)))))

(define u-boot-vf2-bootloader
  (bootloader
   (inherit u-boot-bootloader)
   (package u-boot-vf2)
   (disk-image-installer install-vf2-u-boot)))

(define vf2-barebones-os
  (operating-system
    (host-name "vf2")
    (timezone "America/Los_Angles")
    (locale "en_US.utf8")
    (bootloader (bootloader-configuration
                 (bootloader u-boot-vf2-bootloader)
                 (targets '("/dev/mmcblk1"))))
    (initrd-modules '())
    (kernel linux-vf2)
    (file-systems (cons (file-system
                          (device (file-system-label "root"))
                          (mount-point "/")
                          (type "ext4"))
                        %base-file-systems))
    (services (cons*
               (service agetty-service-type
                        (agetty-configuration
                         (extra-options '("-L")) ; no carrier detect
                         (baud-rate "115200")
                         (term "vt100")
                         (tty "ttyS0")))
               (service dhcp-client-service-type)
               ;;(service ntp-service-type)
               %base-services))
    (packages (cons nss-certs %base-packages))))

(define vf2-raw-image-type
  (image-type
   (name 'vf2-raw-image-type)
   (constructor
    (lambda (os)
      (image
       (inherit (raw-with-offset-disk-image))
       (operating-system os)
       (platform riscv64-linux))))))

;;#|
(image
 (inherit
  (os+platform->image vf2-barebones-os riscv64-linux
                      #:type vf2-raw-image-type))
 (name 'vf2-barebones-image))
;;|#

;;linux-vf2
;;u-boot-vf2
;;opensbi-vf2

;; --- last line ---
